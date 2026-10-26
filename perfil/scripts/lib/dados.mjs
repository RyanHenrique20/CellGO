// ============================================================================
//  dados.mjs — le os dados do GitHub e converte em "progresso de jogo"
// ============================================================================

import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const AQUI = dirname(fileURLToPath(import.meta.url));
export const RAIZ = join(AQUI, '..', '..');
const SNAPSHOT = join(RAIZ, 'data', 'snapshot.json');

// ---------------------------------------------------------------------------
// regras do jogo (documentadas no README)
// ---------------------------------------------------------------------------
export const REGRAS = {
  xpPorCommit: 20,
  xpPorPR: 100,
  xpPorIssue: 60,
  xpPorNivel: 150,
};

export const PATENTES = [
  { ate: 2, nome: 'CADETE', cor: '#7c88ad' },
  { ate: 4, nome: 'PILOTO', cor: '#22d3ee' },
  { ate: 6, nome: 'CAÇADOR', cor: '#67e8f9' },
  { ate: 9, nome: 'COMANDANTE', cor: '#a855f7' },
  { ate: 14, nome: 'ALMIRANTE', cor: '#f472b6' },
  { ate: Infinity, nome: 'LENDA GALÁCTICA', cor: '#fbbf24' },
];

export const patente = (nivel) => PATENTES.find((p) => nivel <= p.ate);

// ---------------------------------------------------------------------------
// entrada de dados
// ---------------------------------------------------------------------------

export async function carregarDados({ offline = false, login = 'RyanHenrique20', token = process.env.GITHUB_TOKEN } = {}) {
  const snap = JSON.parse(readFileSync(SNAPSHOT, 'utf8'));
  if (offline || !token) return normalizar(snap, snap);

  try {
    const fresco = await buscarGitHub(login, token);
    const dados = normalizar(fresco, snap);
    // se a API falhou em trazer algo, o normalizar ja cai no snapshot
    dados.fonte = 'api';
    return dados;
  } catch (erro) {
    console.warn(`⚠️  API do GitHub indisponível (${erro.message}). Usando snapshot local.`);
    const dados = normalizar(snap, snap);
    dados.fonte = 'snapshot';
    return dados;
  }
}

async function gql(query, variaveis, token) {
  const resp = await fetch('https://api.github.com/graphql', {
    method: 'POST',
    headers: {
      Authorization: `bearer ${token}`,
      'Content-Type': 'application/json',
      'User-Agent': 'perfil-arcade',
    },
    body: JSON.stringify({ query, variables: variaveis }),
  });
  if (!resp.ok) throw new Error(`GraphQL ${resp.status}`);
  const json = await resp.json();
  if (json.errors?.length) throw new Error(json.errors[0].message);
  return json.data;
}

export async function buscarGitHub(login, token) {
  const query = `query($login:String!){
    user(login:$login){
      createdAt
      contributionsCollection{
        totalCommitContributions totalPullRequestContributions totalIssueContributions totalRepositoryContributions
        contributionCalendar{ totalContributions weeks{ contributionDays{ date contributionCount } } }
        commitContributionsByRepository(maxRepositories:20){
          repository{ nameWithOwner primaryLanguage{name} }
          contributions{ totalCount }
        }
      }
      repositories(first:40, privacy:PUBLIC, ownerAffiliations:OWNER, isFork:false, orderBy:{field:UPDATED_AT, direction:DESC}){
        totalCount
        nodes{ name description url primaryLanguage{name} stargazerCount updatedAt }
      }
    }
  }`;
  const u = (await gql(query, { login }, token)).user;
  const cc = u.contributionsCollection;

  let commits = [];
  try {
    const resp = await fetch(
      `https://api.github.com/search/commits?q=author:${login}&sort=author-date&order=desc&per_page=30`,
      {
        headers: {
          Authorization: `bearer ${token}`,
          Accept: 'application/vnd.github+json',
          'User-Agent': 'perfil-arcade',
        },
      }
    );
    if (resp.ok) {
      const j = await resp.json();
      commits = (j.items || []).map((c) => ({
        sha: c.sha.slice(0, 7),
        data: c.commit.author.date,
        repo: c.repository.full_name.split('/').pop(),
        mensagem: c.commit.message.split('\n')[0].trim(),
      }));
    }
  } catch {
    /* a busca de commits e' opcional */
  }

  return {
    login,
    geradoEm: new Date().toISOString().replace(/\.\d+Z$/, 'Z'),
    calendar: cc.contributionCalendar,
    totais: {
      commits: cc.totalCommitContributions,
      prs: cc.totalPullRequestContributions,
      issues: cc.totalIssueContributions,
      reposNovos: cc.totalRepositoryContributions,
      contribuicoes: cc.contributionCalendar.totalContributions,
      reposPublicos: u.repositories.totalCount,
    },
    commitsPorRepo: cc.commitContributionsByRepository.map((r) => ({
      repo: r.repository.nameWithOwner,
      commits: r.contributions.totalCount,
      linguagem: r.repository.primaryLanguage?.name || null,
    })),
    repos: u.repositories.nodes.map((r) => ({
      nome: r.name,
      descricao: r.description || '',
      url: r.url,
      linguagem: r.primaryLanguage?.name || null,
      estrelas: r.stargazerCount,
      atualizado: r.updatedAt,
    })),
    commitsRecentes: commits,
  };
}

// ---------------------------------------------------------------------------
// formato do snapshot (o mesmo lido por carregarDados)
// ---------------------------------------------------------------------------
export function paraSnapshot(bruto) {
  return {
    login: bruto.login,
    geradoEm: new Date().toISOString().replace(/\.\d+Z$/, 'Z'),
    totais: bruto.totais,
    calendario: {
      total: bruto.calendar.totalContributions,
      semanas: bruto.calendar.weeks.map((sem) =>
        sem.contributionDays.map((dia) => ({ data: dia.date, n: dia.contributionCount }))
      ),
    },
    commitsRecentes: bruto.commitsRecentes,
    commitsPorRepo: bruto.commitsPorRepo,
    repos: bruto.repos,
  };
}

// ---------------------------------------------------------------------------
// normalizacao + metricas
// ---------------------------------------------------------------------------

function normalizar(bruto, snap) {
  const cal = bruto.calendar || bruto.calendario;
  const semanas = cal.weeks
    ? cal.weeks.map((s) => s.contributionDays.map((d) => ({ data: d.date, n: d.contributionCount })))
    : cal.semanas.map((s) => s.map((d) => ({ data: d.data, n: d.n })));

  const recentes = (bruto.commitsRecentes?.length ? bruto.commitsRecentes : snap.commitsRecentes).map((c) => ({
    ...c,
    tipo: c.tipo || classificar(c.mensagem),
  }));

  const repos = bruto.repos || snap.repos;
  const commitsPorRepo = bruto.commitsPorRepo || snap.commitsPorRepo;
  const t = bruto.totais;

  const dias = semanas.flat();
  const ativos = dias.filter((d) => d.n > 0);
  const hoje = new Date();
  const iso = (d) => d.toISOString().slice(0, 10);

  // sequencia atual: terminando hoje ou ontem
  const mapa = new Map(dias.map((d) => [d.data, d.n]));
  let sequenciaAtual = 0;
  const cursor = new Date(hoje);
  if (!mapa.get(iso(cursor))) cursor.setUTCDate(cursor.getUTCDate() - 1);
  while (mapa.get(iso(cursor))) {
    sequenciaAtual++;
    cursor.setUTCDate(cursor.getUTCDate() - 1);
  }

  // recorde
  let recorde = 0;
  let corrida = 0;
  for (const d of dias) {
    if (d.n > 0) {
      corrida++;
      recorde = Math.max(recorde, corrida);
    } else corrida = 0;
  }

  const linguagens = [...new Set([...repos.map((r) => r.linguagem), ...commitsPorRepo.map((r) => r.linguagem)].filter(Boolean))];
  const reposComCommits = commitsPorRepo.length;

  const xp = t.commits * REGRAS.xpPorCommit + t.prs * REGRAS.xpPorPR + t.issues * REGRAS.xpPorIssue;
  const nivel = 1 + Math.floor(xp / REGRAS.xpPorNivel);
  const xpNoNivel = xp % REGRAS.xpPorNivel;

  const porTipo = {};
  for (const c of recentes) porTipo[c.tipo] = (porTipo[c.tipo] || 0) + 1;

  const dados = {
    login: bruto.login || snap.login,
    geradoEm: new Date().toISOString().replace(/\.\d+Z$/, 'Z'),
    fonte: 'snapshot',
    totais: { ...t },
    semanas,
    dias,
    ativos: ativos.length,
    melhorDia: Math.max(0, ...dias.map((d) => d.n)),
    ultimoAtivo: ativos.length ? ativos[ativos.length - 1].data : null,
    sequenciaAtual,
    recorde,
    linguagens,
    porTipo,
    commitsRecentes: recentes,
    commitsPorRepo,
    repos,
    xp,
    nivel,
    xpNoNivel,
    patente: patente(nivel),
    reposComCommits,
  };

  dados.conquistas = montarConquistas(dados);
  return dados;
}

function classificar(msg = '') {
  const m = msg.toLowerCase();
  if (m.startsWith('merge')) return 'merge';
  if (/^(feat|feature)[:(]/.test(m)) return 'feat';
  if (/^fix[:(]/.test(m)) return 'fix';
  if (/^(docs|doc)[:(]/.test(m)) return 'docs';
  if (/^(refactor|style|test)[:(]/.test(m)) return 'refactor';
  if (/^(chore|build|ci)[:(]/.test(m)) return 'chore';
  if (m.includes('readme')) return 'docs';
  return 'outro';
}

function montarConquistas(d) {
  return [
    { id: 'contato', nome: 'PRIMEIRO CONTATO', desc: '1º commit enviado', ok: d.totais.commits >= 1, valor: d.totais.commits, meta: 1 },
    { id: 'motores', nome: 'MOTORES LIGADOS', desc: '10 commits na temporada', ok: d.totais.commits >= 10, valor: d.totais.commits, meta: 10 },
    { id: 'meio', nome: 'MEIO SÉCULO', desc: '50 commits na temporada', ok: d.totais.commits >= 50, valor: d.totais.commits, meta: 50 },
    { id: 'centuriao', nome: 'CENTURIÃO', desc: '100 commits na temporada', ok: d.totais.commits >= 100, valor: d.totais.commits, meta: 100 },
    { id: 'maratona', nome: 'MARATONA', desc: '3 dias seguidos de código', ok: d.recorde >= 3, valor: d.recorde, meta: 3 },
    { id: 'semana', nome: 'SEMANA ESTELAR', desc: '7 dias seguidos de código', ok: d.recorde >= 7, valor: d.recorde, meta: 7 },
    { id: 'poliglota', nome: 'POLIGLOTA', desc: '3 linguagens no radar', ok: d.linguagens.length >= 3, valor: d.linguagens.length, meta: 3 },
    { id: 'construtor', nome: 'CONSTRUTOR', desc: '5 repositórios com commits', ok: d.reposComCommits >= 5, valor: d.reposComCommits, meta: 5 },
    { id: 'pesado', nome: 'DIA PESADO', desc: '10 commits em um dia', ok: d.melhorDia >= 10, valor: d.melhorDia, meta: 10 },
    { id: 'almirante', nome: 'ALMIRANTE', desc: 'alcançar o nível 10', ok: d.nivel >= 10, valor: d.nivel, meta: 10 },
  ];
}

export const fmtData = (iso) => {
  if (!iso) return '--/--';
  const [a, m, dia] = iso.slice(0, 10).split('-');
  return `${dia}/${m}/${a.slice(2)}`;
};

export const pad = (v, tam = 6) => String(v).padStart(tam, '0');
