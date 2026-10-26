// ============================================================================
//  cenas.mjs — as telas do "perfil arcade"
// ============================================================================

import {
  PAL,
  FONTE,
  txt,
  estrelas,
  nebulosa,
  asteroide,
  asteroidePath,
  nave,
  painel,
  cantos,
  barra,
  scanlines,
  rastro,
  gradienteTexto,
  glow,
  fundoVignette,
  documento,
  n,
  rng,
} from './svg.mjs';
import { cssMotor, asteroideCommit, cinturao } from './motor.mjs';
import { REGRAS, fmtData, pad } from './dados.mjs';

// ===========================================================================
// 1. CABEÇALHO
// ===========================================================================
export function cabecalho(d, { previa = false } = {}) {
  const W = 1200;
  const H = 344;
  const neb = nebulosa({ w: W, h: H, seed: 21, qtd: 5, prefixo: 'nebH' });
  const css = cssMotor({ ciclo: 13, vx: -250, vy: 70 });

  const chip = `
    <g>
      <rect x="426" y="42" width="348" height="27" rx="13.5" fill="rgba(34,211,238,0.06)" stroke="rgba(34,211,238,0.30)" stroke-width="1"/>
      <rect x="440" y="51" width="4" height="9" fill="${PAL.ciano}"/>
      <rect x="446" y="51" width="4" height="9" fill="${PAL.ciano}" opacity="0.5"/>
      ${txt(458, 61, 10.5, PAL.ciano2, 'PLAYER 01', { esp: 2.6 })}
      ${txt(546, 61, 10.5, PAL.fraco2, '|')}
      ${txt(562, 61, 10.5, PAL.fraco, 'SÃO PAULO · BRASIL', { esp: 2.6, peso: 400 })}
      ${txt(1124, 61, 10.5, PAL.fraco2, 'v2.0', { ancora: 'end', esp: 1.4, peso: 400 })}
    </g>`;

  const titulo = `
    <g filter="url(#brilhoTitulo)">
      ${txt(600, 166, 68, '#2a1458', 'RYAN HENRIQUE', { ancora: 'middle', esp: 2, estilo: 'transform: translate(4px,5px)' })}
      ${txt(600, 166, 68, 'url(#gradTitulo)', 'RYAN HENRIQUE', { ancora: 'middle', esp: 2 })}
    </g>
    <rect x="392" y="182" width="416" height="1" fill="url(#linhaTitulo)" opacity="0.7"/>
    ${txt(600, 208, 15, PAL.ciano2, 'DESENVOLVEDOR WEB EM FORMAÇÃO', { ancora: 'middle', esp: 5.4 })}
    ${txt(600, 234, 10.5, PAL.fraco, 'UNICID  ·  23 ANOS  ·  SÃO PAULO', { ancora: 'middle', esp: 3.4, peso: 400 })}`;

  const planeta = `
    <g transform="translate(1052,92)">
      <ellipse cx="0" cy="0" rx="62" ry="15" fill="none" stroke="${PAL.roxo2}" stroke-width="3" opacity="0.42" transform="rotate(-18)"/>
      <circle r="38" fill="url(#gradPlaneta)"/>
      <path d="M-38 0 A38 38 0 0 0 38 0 Z" fill="#000000" opacity="0.28"/>
      <circle cx="-14" cy="-13" r="7" fill="#1b2340" opacity="0.55"/>
      <circle cx="10" cy="10" r="5" fill="#1b2340" opacity="0.5"/>
      <circle cx="17" cy="-16" r="3.4" fill="#1b2340" opacity="0.45"/>
      <circle r="46" fill="none" stroke="${PAL.roxo2}" stroke-width="1" opacity="0.25"/>
      <ellipse cx="0" cy="0" rx="62" ry="15" fill="none" stroke="${PAL.roxo2}" stroke-width="2.4" opacity="0.55" transform="rotate(-18)" stroke-dasharray="120 130"/>
    </g>
    <g transform="translate(1000,150) scale(0.75)" opacity="0.75">
      <g class="flutua" style="animation-delay:-1.2s">
        <circle r="7" fill="${PAL.roxo}"/>
        <circle cx="-2" cy="-2" r="2" fill="#1b2340" opacity="0.6"/>
      </g>
    </g>`;

  const naveHero = `
    <g transform="translate(148,222)">
      <path d="M-112 34 C -70 8, -34 6, 4 14" stroke="${PAL.ciano}" stroke-width="1" stroke-dasharray="3 7" fill="none" opacity="0.35"/>
      <g class="flutua">
        <g transform="scale(1.85)">${nave(0, 0, 1)}</g>
      </g>
      ${txt(0, 62, 9, PAL.fraco2, '1UP', { ancora: 'middle', esp: 2.6 })}
    </g>`;

  // asteroides decorativos que estouram
  const asteroides = [
    { x: 1160, y: 8, raio: 11, seed: 4, delay: 2.1, giro: 7 },
    { x: 1410, y: 186, raio: 9, seed: 9, delay: 8.4, giro: 5.5 },
  ]
    .map((a, i) =>
      asteroideCommit({ ...a, vx: -250, vy: 70, cor: PAL.ciano, comXP: false, fase: previa ? (i === 0 ? 0.388 : 0.15) : null })
    )
    .join('');

  const estaticos = `
    <g transform="translate(86,96) rotate(-12)">${asteroide(9, 33)}</g>
    <g transform="translate(300,288) rotate(24)">${asteroide(6, 34)}</g>
    <g transform="translate(1152,282) rotate(8)">${asteroide(7, 35)}</g>
    <g transform="translate(660,300) rotate(-20)">${asteroide(4.5, 36)}</g>`;

  const barraRodape = `
    <g>
      <rect x="0" y="300" width="${W}" height="44" fill="#05070f" opacity="0.92"/>
      <line x1="0" y1="300" x2="${W}" y2="300" stroke="${PAL.linha}" stroke-width="1"/>
      <line x1="0" y1="300" x2="${W}" y2="300" stroke="${PAL.ciano}" stroke-width="1" opacity="0.35"/>
      ${txt(24, 326, 11, PAL.fraco, 'SCORE', { esp: 2.4, peso: 400 })}
      ${txt(80, 327, 15, PAL.ambar, pad(d.xp), { esp: 2 })}
      <line x1="208" y1="312" x2="208" y2="332" stroke="${PAL.linha2}"/>
      ${txt(226, 326, 11, PAL.fraco, 'NÍVEL', { esp: 2.4, peso: 400 })}
      ${txt(282, 327, 15, PAL.ciano2, pad(d.nivel, 3), { esp: 2 })}
      <line x1="348" y1="312" x2="348" y2="332" stroke="${PAL.linha2}"/>
      ${txt(366, 326, 11, PAL.fraco, 'PATENTE', { esp: 2.4, peso: 400 })}
      ${txt(438, 327, 13, d.patente.cor, d.patente.nome, { esp: 2.4 })}
      <g class="cursor">${txt(806, 327, 12, PAL.ciano, '► INSIRA UMA MOEDA', { ancora: 'middle', esp: 2.4 })}</g>
      ${txt(1176, 326, 11, PAL.fraco, `TEMPORADA ${new Date().getFullYear()}`, { ancora: 'end', esp: 2, peso: 400 })}
      ${txt(1176, 340, 8.5, PAL.fraco2, 'DADOS SINCRONIZADOS COM O GITHUB', { ancora: 'end', esp: 1.2, peso: 400 })}
    </g>`;

  const defs = `
    ${neb.defs}
    ${gradienteTexto('gradTitulo', ['#67e8f9', '#a855f7', '#f472b6'])}
    ${glow('brilhoTitulo', 3)}
    <linearGradient id="linhaTitulo" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0%" stop-color="${PAL.ciano}" stop-opacity="0"/>
      <stop offset="50%" stop-color="${PAL.roxo2}" stop-opacity="0.9"/>
      <stop offset="100%" stop-color="${PAL.ciano}" stop-opacity="0"/>
    </linearGradient>
    <radialGradient id="gradPlaneta" cx="34%" cy="30%" r="78%">
      <stop offset="0%" stop-color="#4c1d95"/>
      <stop offset="55%" stop-color="#2e1065"/>
      <stop offset="100%" stop-color="#12081f"/>
    </radialGradient>
    <linearGradient id="ceuHero" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#070a1c"/>
      <stop offset="55%" stop-color="#05060f"/>
      <stop offset="100%" stop-color="#04050d"/>
    </linearGradient>
    ${fundoVignette(W, H, 'vigHero')}`;

  const corpo = `
  <rect width="${W}" height="${H}" fill="url(#ceuHero)"/>
  ${neb.out}
  ${estrelas({ w: W, h: 300, seed: 5, qtd: 110 })}
  ${estrelas({ w: W, h: 300, seed: 6, qtd: 26, brilho: 1 })}
  <rect width="${W}" height="${H}" fill="url(#vigHero)"/>
  ${planeta}
  ${estaticos}
  ${naveHero}
  ${chip}
  ${titulo}
  ${asteroides}
  ${barraRodape}
  ${scanlines({ w: W, h: H, op: 0.05 })}`;

  return documento({
    w: W,
    h: H,
    titulo: 'Ryan Henrique — desenvolvedor web em formação',
    defs,
    css,
    corpo,
    previa,
  });
}

// ===========================================================================
// 2. CAMPO DE ASTEROIDES (commits)
// ===========================================================================
export function campo(d, { previa = false } = {}) {
  const W = 1200;
  const H = 480;
  const X = 16;
  const Y = 62;
  const LW = 818;
  const LH = 348;
  const PX = 848;
  const PW = 336;

  const neb = nebulosa({ w: W, h: H, seed: 44, qtd: 3, prefixo: 'nebC' });
  const css =
    cssMotor({ ciclo: 16, vx: -720, vy: 86 }) +
    `
  .varre { animation: varrer 5s linear infinite; transform-box: fill-box; transform-origin: 0 0; }
  @keyframes varrer { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
  `.replace('transform-origin: 0 0', 'transform-origin: center');

  // quantos asteroides animados cabem na cena (o resto fica no cinturão)
  const ativos = Math.min(10, Math.max(3, Math.ceil(d.totais.commits / 5)));
  const r = rng(77);
  const cores = [PAL.ciano, PAL.roxo2, PAL.rosa, PAL.ambar, PAL.verde];
  let cena = '';
  for (let i = 0; i < ativos; i++) {
    // 3 colunas de impacto; a pedra entra pela direita e cruza o setor
    const col = i % 3;
    const destX = 76 + col * 104 + r() * 26;
    const sx = destX + 720;
    const sy = 74 + ((i * 3) % 5) * 50 + r() * 18;
    cena += asteroideCommit({
      x: sx,
      y: sy,
      raio: 12 + Math.round(r() * 8),
      seed: 100 + i * 7,
      delay: (i * 16) / ativos + r() * 0.7,
      cor: cores[i % cores.length],
      vx: -720,
      vy: 86,
      giro: 4 + r() * 4,
      fase: previa ? (i === 1 ? 0.388 : 0.1 + ((i * 3) % 7) * 0.031) : null,
    });
  }

  const grade = (() => {
    let g = '';
    for (let x = X + 26; x < X + LW; x += 46)
      g += `<line x1="${x}" y1="${Y + 12}" x2="${x}" y2="${Y + LH - 10}" stroke="${PAL.ciano}" stroke-width="0.5" opacity="0.05"/>`;
    for (let y = Y + 26; y < Y + LH; y += 46)
      g += `<line x1="${X + 10}" y1="${y}" x2="${X + LW - 10}" y2="${y}" stroke="${PAL.ciano}" stroke-width="0.5" opacity="0.05"/>`;
    return g;
  })();

  // log de commits
  const entradas = (d.commitsRecentes.length ? d.commitsRecentes : []).slice(0, 7);
  const coresTipo = {
    feat: PAL.ciano,
    fix: PAL.ambar,
    docs: PAL.roxo2,
    merge: PAL.verde,
    refactor: PAL.rosa,
    chore: PAL.fraco,
    outro: PAL.texto,
  };
  const log = entradas
    .map((c, i) => {
      const y = 102 + i * 41;
      const cor = coresTipo[c.tipo] || PAL.texto;
      const msg = c.mensagem.length > 38 ? c.mensagem.slice(0, 37).trimEnd() + '…' : c.mensagem;
      return `<g>
        <rect x="${PX + 14}" y="${y - 11}" width="2.5" height="32" fill="${cor}"/>
        <rect x="${PX + 22}" y="${y - 13}" width="${PW - 36}" height="36" fill="#ffffff" opacity="${i === 0 ? 0.035 : 0.014}" rx="3"/>
        ${txt(PX + 30, y + 1, 10, cor, c.tipo.toUpperCase(), { esp: 1.4 })}
        ${txt(PX + PW - 16, y + 1, 8.5, PAL.fraco2, `${fmtData(c.data)} · ${c.repo}`, { ancora: 'end', esp: 0.2, peso: 400 })}
        ${txt(PX + 30, y + 16, 9.5, PAL.texto, msg, { peso: 400 })}
      </g>`;
    })
    .join('');

  const legenda = `
    <g>
      <rect x="0" y="424" width="${W}" height="56" fill="#05070f" opacity="0.9"/>
      <line x1="0" y1="424" x2="${W}" y2="424" stroke="${PAL.linha}"/>
      <rect x="24" y="443" width="8" height="8" fill="${PAL.ciano}"/>
      ${txt(42, 451, 10.5, PAL.fraco, 'CADA ASTEROIDE = 1 COMMIT', { esp: 1.4, peso: 400 })}
      <rect x="304" y="443" width="8" height="8" fill="${PAL.ambar}"/>
      ${txt(322, 451, 10.5, PAL.fraco, 'IMPACTO = ESTOURO EM BLOCOS', { esp: 1.4, peso: 400 })}
      <rect x="608" y="443" width="8" height="8" fill="${PAL.verde}"/>
      ${txt(626, 451, 10.5, PAL.fraco, `+${REGRAS.xpPorCommit} XP POR ACERTO`, { esp: 1.4, peso: 400 })}
      ${txt(1176, 451, 11, PAL.ciano2, `${d.totais.commits} COMMITS · ${d.totais.contribuicoes} CONTRIBUIÇÕES`, { ancora: 'end', esp: 1.6 })}
    </g>`;

  const defs = `
    ${neb.defs}
    <linearGradient id="ceuCampo" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#070a1c"/><stop offset="100%" stop-color="#04050d"/>
    </linearGradient>
    <linearGradient id="ceuSetor" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#0a1024"/><stop offset="100%" stop-color="#05070f"/>
    </linearGradient>
    ${fundoVignette(W, H, 'vigCampo')}`;

  const corpo = `
  <rect width="${W}" height="${H}" fill="url(#ceuCampo)"/>
  ${neb.out}
  ${estrelas({ w: W, h: 420, seed: 12, qtd: 90 })}

  ${txt(24, 30, 14, PAL.texto, 'CAMPO DE ASTEROIDES', { esp: 4 })}
  ${txt(24, 46, 9.5, PAL.fraco2, 'SETOR 07 · COMMITS DETECTADOS NO RADAR', { esp: 1.6, peso: 400 })}
  <g transform="translate(1124,26)">
    <circle cx="0" cy="0" r="3" fill="${PAL.verde}"/>
    <circle cx="0" cy="0" r="6" fill="none" stroke="${PAL.verde}" stroke-width="1" opacity="0.5"/>
    ${txt(14, 3.5, 9.5, PAL.fraco, 'AO VIVO', { esp: 1.6, peso: 400 })}
  </g>

  ${painel(X, Y, LW, LH, { fill: 'url(#ceuSetor)', corCanto: PAL.ciano, tam: 16 })}
  <clipPath id="recorteCampo"><rect x="${X + 1}" y="${Y + 1}" width="${LW - 2}" height="${LH - 2}" rx="7"/></clipPath>
  <g clip-path="url(#recorteCampo)">
    ${estrelas({ w: LW, h: LH, seed: 13, qtd: 60, x0: X, y0: Y })}
    ${grade}
    ${cinturao({ qtd: d.totais.commits, caixa: { x: X, y: Y, w: LW, h: LH } })}
    ${cena}
    ${rastro(X + 60, Y + LH - 40, 120, -22, PAL.roxo2, 0.35)}
    <g transform="translate(${X + LW - 96},${Y + LH - 84})" opacity="0.85">
      <circle r="56" fill="none" stroke="${PAL.ciano}" stroke-width="0.8" opacity="0.16"/>
      <circle r="38" fill="none" stroke="${PAL.ciano}" stroke-width="0.8" opacity="0.13"/>
      <circle r="19" fill="none" stroke="${PAL.ciano}" stroke-width="0.8" opacity="0.12"/>
      <line x1="-56" y1="0" x2="56" y2="0" stroke="${PAL.ciano}" stroke-width="0.6" opacity="0.12"/>
      <line x1="0" y1="-56" x2="0" y2="56" stroke="${PAL.ciano}" stroke-width="0.6" opacity="0.12"/>
      <g class="varre">
        <path d="M0 0 L56 0 A56 56 0 0 0 39.6 -39.6 Z" fill="${PAL.ciano}" opacity="0.13"/>
        <line x1="0" y1="0" x2="56" y2="0" stroke="${PAL.ciano}" stroke-width="1.2" opacity="0.55"/>
      </g>
      <circle cx="22" cy="-30" r="2" fill="${PAL.verde}" opacity="0.8"/>
      <circle cx="-34" cy="18" r="1.6" fill="${PAL.ambar}" opacity="0.7"/>
      <circle cx="8" cy="34" r="1.4" fill="${PAL.ciano2}" opacity="0.8"/>
    </g>
  </g>
  <g opacity="0.6">${txt(X + 14, Y + LH - 12, 9, PAL.fraco2, 'RADAR 4.2 · VARREDURA CONTÍNUA', { esp: 1.2, peso: 400 })}</g>
  <g opacity="0.6">${txt(X + LW - 14, Y + LH - 12, 9, PAL.fraco2, `SEQUÊNCIA ${d.recorde} DIAS`, { ancora: 'end', esp: 1.2, peso: 400 })}</g>

  ${painel(PX, Y, PW, LH, { fill: 'rgba(6,9,20,0.85)', corCanto: PAL.roxo2, tam: 14 })}
  <rect x="${PX}" y="${Y}" width="${PW}" height="34" rx="7" fill="#0b1022"/>
  <rect x="${PX}" y="${Y + 27}" width="${PW}" height="7" fill="#0b1022"/>
  <line x1="${PX}" y1="${Y + 34}" x2="${PX + PW}" y2="${Y + 34}" stroke="${PAL.linha2}"/>
  <circle cx="${PX + 16}" cy="${Y + 17}" r="3" fill="${PAL.vermelho}" opacity="0.8"/>
  <circle cx="${PX + 28}" cy="${Y + 17}" r="3" fill="${PAL.ambar}" opacity="0.8"/>
  <circle cx="${PX + 40}" cy="${Y + 17}" r="3" fill="${PAL.verde}" opacity="0.8"/>
  ${txt(PX + 56, Y + 21, 10, PAL.fraco, 'LOG DE COMMITS', { esp: 2.4 })}
  ${txt(PX + PW - 14, Y + 21, 9, PAL.fraco2, '--recentes', { ancora: 'end', peso: 400 })}
  ${log}
  ${txt(PX + 16, Y + LH - 14, 9, PAL.fraco2, '> _', { esp: 1, cls: 'cursor' })}

  ${legenda}
  ${scanlines({ w: W, h: H, op: 0.045 })}`;

  return documento({
    w: W,
    h: H,
    titulo: `Campo de asteroides: ${d.totais.commits} commits, cada asteroide estoura em blocos`,
    defs,
    css,
    corpo,
    previa,
  });
}

// ===========================================================================
// 3. PAINEL DO JOGADOR + CONQUISTAS
// ===========================================================================
const ICONES = {
  contato: (c) => `<circle cx="0" cy="0" r="4.5" fill="${c}"/><circle r="8" fill="none" stroke="${c}" stroke-width="1.1" opacity="0.6"/>`,
  motores: (c) => `<path d="M0 -9 L5 3 L0 8 L-5 3 Z" fill="${c}"/><path d="M-3 8 L0 13 L3 8 Z" fill="${c}" opacity="0.65"/>`,
  meio: (c) => `<path d="M-8 0 A8 8 0 0 1 8 0 Z" fill="${c}"/><line x1="-9" y1="0" x2="9" y2="0" stroke="${c}" stroke-width="1.4"/>`,
  centuriao: (c) => `<path d="M0 -9 L2.6 -2.8 L9 -2.2 L4.2 2.2 L5.6 8.8 L0 5.4 L-5.6 8.8 L-4.2 2.2 L-9 -2.2 L-2.6 -2.8 Z" fill="${c}"/>`,
  maratona: (c) => `<path d="M0 9 C-6 4 -5 -1 -1 -5 C-1 -1 3 -2 2 -6 C6 -2 6 4 0 9 Z" fill="${c}"/>`,
  semana: (c) => [-8, -4.5, -1, 2.5, 6, 9.5].map((x) => `<circle cx="${x - 1}" cy="2" r="1.9" fill="${c}"/>`).join('') + `<circle cx="11" cy="-4" r="2.6" fill="${c}"/>`,
  poliglota: (c) => `<circle cx="-4" cy="1" r="5.5" fill="${c}" opacity="0.55"/><circle cx="4" cy="1" r="5.5" fill="${c}" opacity="0.8"/><circle cx="0" cy="-4" r="5.5" fill="${c}" opacity="0.4"/>`,
  construtor: (c) => `<rect x="-8" y="-8" width="7" height="7" fill="${c}"/><rect x="1" y="-8" width="7" height="7" fill="${c}" opacity="0.6"/><rect x="-8" y="1" width="7" height="7" fill="${c}" opacity="0.6"/><rect x="1" y="1" width="7" height="7" fill="${c}" opacity="0.35"/>`,
  pesado: (c) => `<rect x="-8" y="-6" width="16" height="12" fill="${c}" opacity="0.35" stroke="${c}" stroke-width="1.2"/><line x1="-4" y1="-6" x2="-4" y2="6" stroke="${c}"/><line x1="4" y1="-6" x2="4" y2="6" stroke="${c}"/>`,
  almirante: (c) => `<path d="M-9 5 L-9 -4 L-4.5 1 L0 -7 L4.5 1 L9 -4 L9 5 Z" fill="${c}"/>`,
};

export function painelJogador(d, { previa = false } = {}) {
  const W = 1200;
  const H = 452;
  const LX = 16;
  const LY = 64;
  const LW = 348;
  const LH = 352;
  const RX = 384;
  const RW = 1200 - RX - 16;

  const neb = nebulosa({ w: W, h: H, seed: 88, qtd: 3, prefixo: 'nebP' });
  const pct = d.xpNoNivel / REGRAS.xpPorNivel;
  const faltam = REGRAS.xpPorNivel - d.xpNoNivel;

  // ---- cartao de status
  const stat = `
    <g>
      <rect x="${LX + 12}" y="${LY + 12}" width="${LW - 24}" height="70" rx="4" fill="#0b1024" stroke="${PAL.linha2}"/>
      ${txt(LX + 24, LY + 32, 9, PAL.fraco, 'NÍVEL ATUAL', { esp: 2.2, peso: 400 })}
      ${txt(LX + 24, LY + 66, 34, 'url(#gradNivel)', pad(d.nivel, 3), { esp: 1 })}
      ${txt(LX + LW - 24, LY + 30, 9.5, PAL.fraco, 'PATENTE', { ancora: 'end', esp: 2, peso: 400 })}
      ${txt(LX + LW - 24, LY + 48, 11.5, d.patente.cor, d.patente.nome, { ancora: 'end', esp: 1.4 })}
      ${txt(LX + LW - 24, LY + 66, 9, PAL.fraco2, 'NÍVEL 10 = ALMIRANTE', { ancora: 'end', esp: 0.6, peso: 400 })}
    </g>
    <g>
      ${txt(LX + 12, LY + 106, 9, PAL.fraco, 'XP DA TEMPORADA', { esp: 2, peso: 400 })}
      ${txt(LX + LW - 12, LY + 106, 10, PAL.ambar, `${d.xp} XP`, { ancora: 'end', esp: 1 })}
      ${barra(LX + 12, LY + 116, LW - 24, 10, pct, { cor: d.patente.cor, bloco: 4, gap: 2 })}
      ${txt(LX + 12, LY + 142, 8.5, PAL.fraco2, `FALTAM ${faltam} XP PARA O NÍVEL ${d.nivel + 1}`, { esp: 0.8, peso: 400 })}
    </g>`;

  const linhas = [
    { rot: 'SEQUÊNCIA ATUAL', val: `${d.sequenciaAtual} DIAS`, cor: PAL.ambar },
    { rot: 'RECORDE DE SEQUÊNCIA', val: `${d.recorde} DIAS`, cor: PAL.rosa },
    { rot: 'MELHOR DIA', val: `${d.melhorDia} COMMITS`, cor: PAL.verde },
    { rot: 'REPOSITÓRIOS', val: `${d.totais.reposPublicos} PÚBLICOS`, cor: PAL.ciano2 },
    { rot: 'PULL REQUESTS', val: `${d.totais.prs}`, cor: PAL.roxo2 },
    { rot: 'ÚLTIMO COMMIT', val: fmtData(d.ultimoAtivo), cor: PAL.texto },
  ];
  const stats = linhas
    .map((l, i) => {
      const y = LY + 166 + i * 27;
      return `<g>
        <rect x="${LX + 12}" y="${y - 9}" width="3" height="10" fill="${l.cor}" opacity="0.85"/>
        ${txt(LX + 22, y, 9, PAL.fraco, l.rot, { esp: 1.2, peso: 400 })}
        ${txt(LX + LW - 12, y, 10.5, l.cor, l.val, { ancora: 'end', esp: 0.8 })}
      </g>`;
    })
    .join('');

  // ---- conquistas
  const cols = 3;
  const cw = (RW - 24) / cols;
  const ch = 54;
  const passo = ch + 5;
  const conquistas = d.conquistas
    .slice(0, 10)
    .map((c, i) => {
      const cx = RX + 12 + (i % cols) * cw;
      const cy = LY + 40 + Math.floor(i / cols) * passo;
      const cor = c.ok ? PAL.ambar : '#2b3450';
      const corIcone = c.ok ? PAL.ambar : '#495570';
      const prog = Math.min(1, c.valor / c.meta);
      return `<g>
        <rect x="${cx}" y="${cy}" width="${cw - 7}" height="${ch}" rx="4" fill="${c.ok ? 'rgba(251,191,36,0.06)' : 'rgba(255,255,255,0.015)'}" stroke="${c.ok ? 'rgba(251,191,36,0.32)' : '#232c46'}" stroke-width="1"/>
        <g transform="translate(${cx + 27},${cy + ch / 2 - 2})">
          <path d="M0 -15 L13 -7.5 L13 7.5 L0 15 L-13 7.5 L-13 -7.5 Z" fill="${c.ok ? 'rgba(251,191,36,0.13)' : '#0d1425'}" stroke="${cor}" stroke-width="1.2"/>
          <g transform="scale(0.82)">${ICONES[c.id] ? ICONES[c.id](corIcone) : ''}</g>
        </g>
        ${txt(cx + 48, cy + 21, 9.5, c.ok ? PAL.ambar : '#66719a', c.nome, { esp: 1 })}
        ${txt(cx + 48, cy + 33, 7.8, PAL.fraco, c.desc, { esp: 0, peso: 400 })}
        ${barra(cx + 48, cy + 40, cw - 108, 5, prog, { cor: c.ok ? PAL.ambar : '#3b4763', bloco: 3, gap: 2 })}
        ${txt(cx + cw - 15, cy + 44, 7.5, c.ok ? PAL.ambar : PAL.fraco2, c.ok ? 'OK' : `${c.valor}/${c.meta}`, { ancora: 'end', esp: 0.4 })}
      </g>`;
    })
    .join('');

  const desbloqueadas = d.conquistas.filter((c) => c.ok).length;

  const defs = `
    ${neb.defs}
    ${gradienteTexto('gradNivel', ['#67e8f9', '#a855f7'])}
    <linearGradient id="ceuPainel" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#080b1e"/><stop offset="100%" stop-color="#04050d"/>
    </linearGradient>
    ${fundoVignette(W, H, 'vigPainel')}`;

  const corpo = `
  <rect width="${W}" height="${H}" fill="url(#ceuPainel)"/>
  ${neb.out}
  ${estrelas({ w: W, h: H, seed: 31, qtd: 80 })}
  <rect width="${W}" height="${H}" fill="url(#vigPainel)"/>

  ${txt(24, 30, 14, PAL.texto, 'PAINEL DO JOGADOR', { esp: 4 })}
  ${txt(24, 46, 9.5, PAL.fraco2, `STATUS, XP E CONQUISTAS · TEMPORADA ${new Date().getFullYear()}`, { esp: 1.6, peso: 400 })}
  <g transform="translate(1176,30)">
    ${txt(0, 0, 10, PAL.fraco, `${desbloqueadas}/${d.conquistas.length} CONQUISTAS`, { ancora: 'end', esp: 1.6 })}
    ${barra(0 - 140, 8, 140, 5, desbloqueadas / d.conquistas.length, { cor: PAL.ambar, bloco: 3, gap: 2 })}
  </g>

  ${painel(LX, LY, LW, LH, { fill: 'rgba(6,9,20,0.82)', corCanto: PAL.ciano })}
  ${txt(LX + 14, LY + 20, 9.5, PAL.fraco, 'HUD', { esp: 3 })}
  <line x1="${LX + 12}" y1="${LY + 28}" x2="${LX + LW - 12}" y2="${LY + 28}" stroke="${PAL.linha}"/>
  ${stat}
  <line x1="${LX + 12}" y1="${LY + 154}" x2="${LX + LW - 12}" y2="${LY + 154}" stroke="${PAL.linha}"/>
  ${stats}

  ${painel(RX, LY, RW, LH, { fill: 'rgba(6,9,20,0.82)', corCanto: PAL.roxo2 })}
  ${txt(RX + 14, LY + 20, 9.5, PAL.fraco, 'RADAR DE CONQUISTAS', { esp: 3 })}
  ${txt(RX + RW - 14, LY + 20, 9, PAL.fraco2, `DESBLOQUEADAS ${desbloqueadas}/${d.conquistas.length}`, { ancora: 'end', esp: 1.2, peso: 400 })}
  <line x1="${RX + 12}" y1="${LY + 28}" x2="${RX + RW - 12}" y2="${LY + 28}" stroke="${PAL.linha}"/>
  ${conquistas}
  <line x1="${RX + 12}" y1="${LY + LH - 22}" x2="${RX + RW - 12}" y2="${LY + LH - 22}" stroke="${PAL.linha}"/>
  ${txt(RX + 14, LY + LH - 9, 8, PAL.fraco2, 'CONQUISTAS CALCULADAS A PARTIR DOS DADOS PÚBLICOS DO GITHUB', { esp: 1, peso: 400 })}
  ${txt(RX + RW - 14, LY + LH - 9, 8, PAL.ambar, `+${REGRAS.xpPorCommit} XP/COMMIT · +${REGRAS.xpPorPR} XP/PR`, { ancora: 'end', esp: 0.8, peso: 400 })}

  ${scanlines({ w: W, h: H, op: 0.045 })}`;

  return documento({ w: W, h: H, titulo: 'Painel do jogador: XP, nível e conquistas', defs, css: '', corpo, previa });
}

// ===========================================================================
// 4. MAPA ESTELAR (atividade + setores)
// ===========================================================================
export function mapaEstelar(d, { previa = false } = {}) {
  const W = 1200;
  const H = 470;
  const HY = 110;
  const cel = 14;
  const gap = 3.6;
  const semanas = d.semanas.slice(-53);
  const larguraGrade = semanas.length * (cel + gap) - gap;
  // centraliza a grade no painel, reservando espaco para os rotulos de dia
  const HX = 16 + Math.round((1168 - (larguraGrade + 56)) / 2) + 56;

  const nivelCell = (n) => (n === 0 ? 0 : n < 3 ? 1 : n < 6 ? 2 : n < 12 ? 3 : 4);
  const cores = ['#131c33', '#155e75', '#0e7490', '#22d3ee', '#a5f3fc'];

  let heat = '';
  semanas.forEach((sem, i) => {
    sem.forEach((dia, j) => {
      const x = HX + i * (cel + gap);
      const y = HY + j * (cel + gap);
      const lv = nivelCell(dia.n);
      const cor = cores[lv];
      if (lv === 0) {
        heat += `<rect x="${n(x)}" y="${n(y)}" width="${cel}" height="${cel}" rx="2" fill="${cor}" opacity="0.8"/>`;
      } else if (lv === 1) {
        heat += `<rect x="${n(x)}" y="${n(y)}" width="${cel}" height="${cel}" rx="2" fill="${cor}"/>`;
      } else {
        heat += `<g transform="translate(${n(x + cel / 2)},${n(y + cel / 2)})">
          <rect x="${-cel / 2}" y="${-cel / 2}" width="${cel}" height="${cel}" rx="2.4" fill="${cor}"/>
          <path d="M${-cel / 2 + 1.5} ${-cel / 5} L${-cel / 8} ${-cel / 2 + 1.5} L${cel / 2 - 1.5} ${-cel / 4} L${cel / 4} ${cel / 2 - 1.5} L${-cel / 3} ${cel / 4} Z" fill="#04050d" opacity="0.2"/>
          ${lv === 4 ? `<circle r="${cel * 0.19}" fill="#ffffff" opacity="0.75"/>` : ''}
        </g>`;
      }
    });
  });

  // rotulos de mes
  const meses = ['JAN', 'FEV', 'MAR', 'ABR', 'MAI', 'JUN', 'JUL', 'AGO', 'SET', 'OUT', 'NOV', 'DEZ'];
  let rotulosMes = '';
  let ultimoMes = -1;
  let ultimoX = -999;
  semanas.forEach((sem, i) => {
    const m = Number(sem[0].data.slice(5, 7)) - 1;
    const x = HX + i * (cel + gap);
    if (m !== ultimoMes && i < semanas.length - 1 && x - ultimoX >= 42) {
      rotulosMes += txt(x, HY - 10, 8.5, PAL.fraco2, meses[m], { esp: 1.4, peso: 400 });
      ultimoMes = m;
      ultimoX = x;
    } else if (m !== ultimoMes && i >= semanas.length - 1) {
      ultimoMes = m;
    }
  });

  const alturaGrade = 7 * (cel + gap) - gap;
  const yLegenda = HY + alturaGrade + 22;
  const legenda = `
    <g>
      ${txt(HX - 12, yLegenda, 8.5, PAL.fraco2, 'MENOS', { ancora: 'end', esp: 1, peso: 400 })}
      ${cores.map((c, i) => `<rect x="${HX - 6 + i * 20}" y="${yLegenda - 9}" width="${cel}" height="${cel}" rx="2" fill="${c}"/>`).join('')}
      ${txt(HX + 5 * 20 + 4, yLegenda, 8.5, PAL.fraco2, 'MAIS', { esp: 1, peso: 400 })}
      ${txt(HX + 5 * 20 + 52, yLegenda, 8.5, PAL.fraco, `${d.totais.contribuicoes} CONTRIBUIÇÕES EM 12 MESES`, { esp: 1.2, peso: 400 })}
      ${txt(HX + larguraGrade, yLegenda, 8.5, PAL.fraco, `${d.ativos} DIAS ATIVOS · RECORDE DE ${d.recorde} DIAS`, { ancora: 'end', esp: 1.2, peso: 400 })}
    </g>`;

  // ---- setores (repos)
  const SY = 300;
  const top = [...d.commitsPorRepo].sort((a, b) => b.commits - a.commits).slice(0, 4);
  const maxC = Math.max(1, ...top.map((t) => t.commits));
  const coresSetor = [PAL.ciano, PAL.roxo2, PAL.rosa, PAL.ambar];
  const setores = top
    .map((t, i) => {
      const x = 24 + i * 288;
      const y = SY;
      const cor = coresSetor[i % 4];
      const raio = 11 + (t.commits / maxC) * 12;
      return `<g>
        <rect x="${x}" y="${y}" width="272" height="96" rx="4" fill="rgba(255,255,255,0.016)" stroke="#1e2742"/>
        <g transform="translate(${x + 38},${y + 48})">
          <circle r="${n(raio + 9)}" fill="${cor}" opacity="0.09"/>
          <circle r="${n(raio)}" fill="url(#gradPlanetaSetor)" stroke="${cor}" stroke-width="1"/>
          <path d="M${n(-raio)} 0 A${n(raio)} ${n(raio)} 0 0 0 ${n(raio)} 0 Z" fill="#04050d" opacity="0.38"/>
          <ellipse rx="${n(raio * 1.95)}" ry="${n(raio * 0.4)}" fill="none" stroke="${cor}" stroke-width="1.4" opacity="0.7" transform="rotate(-16)"/>
          <circle cx="${n(raio * 1.4)}" cy="${n(-raio * 0.52)}" r="2.2" fill="${cor}"/>
        </g>
        ${txt(x + 74, y + 28, 10, PAL.texto, t.repo.split('/').pop().slice(0, 20), { esp: 0.5 })}
        ${txt(x + 74, y + 43, 8, PAL.fraco, `${t.commits} COMMITS · ${t.linguagem || 'MULTI'}`, { esp: 0.8, peso: 400 })}
        ${barra(x + 74, y + 54, 176, 5, t.commits / maxC, { cor, bloco: 4, gap: 2 })}
        ${txt(x + 74, y + 76, 7.5, PAL.fraco2, i === 0 ? 'SETOR PRINCIPAL' : 'SETOR ATIVO', { esp: 1.1, peso: 400 })}
      </g>`;
    })
    .join('');

  const defs = `
    <radialGradient id="gradPlanetaSetor" cx="32%" cy="28%" r="80%">
      <stop offset="0%" stop-color="#8b5cf6" stop-opacity="0.95"/>
      <stop offset="45%" stop-color="#4c2a8f" stop-opacity="0.9"/>
      <stop offset="100%" stop-color="#141a33"/>
    </radialGradient>
    <linearGradient id="ceuMapa" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#070a1a"/><stop offset="100%" stop-color="#04050d"/>
    </linearGradient>
    ${fundoVignette(W, H, 'vigMapa')}`;

  const corpo = `
  <rect width="${W}" height="${H}" fill="url(#ceuMapa)"/>
  ${estrelas({ w: W, h: H, seed: 55, qtd: 110 })}
  <rect width="${W}" height="${H}" fill="url(#vigMapa)"/>

  ${txt(24, 30, 14, PAL.texto, 'MAPA ESTELAR', { esp: 4 })}
  ${txt(24, 46, 9.5, PAL.fraco2, 'ATIVIDADE DOS ÚLTIMOS 12 MESES E SETORES EXPLORADOS', { esp: 1.6, peso: 400 })}
  ${txt(1176, 30, 10.5, PAL.ciano2, `${d.totais.commits} COMMITS`, { ancora: 'end', esp: 2 })}
  ${txt(1176, 46, 8.5, PAL.fraco2, `${d.linguagens.length} LINGUAGENS NO RADAR`, { ancora: 'end', esp: 1.6, peso: 400 })}

  ${painel(16, 62, 1168, 196, { fill: 'rgba(6,9,20,0.72)', corCanto: PAL.ciano })}
  ${txt(HX - 12, HY + 5, 7.5, PAL.fraco2, 'SEG', { ancora: 'end', peso: 400 })}
  ${txt(HX - 12, HY + 2 * (cel + gap) + 5, 7.5, PAL.fraco2, 'QUA', { ancora: 'end', peso: 400 })}
  ${txt(HX - 12, HY + 4 * (cel + gap) + 5, 7.5, PAL.fraco2, 'SEX', { ancora: 'end', peso: 400 })}
  ${rotulosMes}
  ${heat}
  ${legenda}

  ${txt(24, 286, 11, PAL.texto, 'SETORES EXPLORADOS', { esp: 3 })}
  ${txt(1176, 286, 8.5, PAL.fraco2, `${d.commitsPorRepo.length} REPOSITÓRIOS COM COMMITS · ${d.repos.length} REPOSITÓRIOS PÚBLICOS`, { ancora: 'end', esp: 1.2, peso: 400 })}
  <line x1="24" y1="294" x2="1176" y2="294" stroke="${PAL.linha}"/>
  ${setores}
  ${txt(24, 424, 8.5, PAL.fraco2, 'CADA SETOR = UM REPOSITÓRIO COM COMMITS NOS ÚLTIMOS 12 MESES', { esp: 1.2, peso: 400 })}
  ${txt(1176, 424, 8.5, PAL.ciano2, `${d.totais.prs} PULL REQUEST · ${d.totais.reposNovos} REPOSITÓRIOS CRIADOS`, { ancora: 'end', esp: 1.2, peso: 400 })}
  ${txt(24, 452, 8, PAL.fraco2, `SINCRONIZADO EM ${d.geradoEm.slice(0, 10).split('-').reverse().join('/')}`, { esp: 1.2, peso: 400 })}

  ${scanlines({ w: W, h: H, op: 0.045 })}`;

  return documento({ w: W, h: H, titulo: 'Mapa estelar: atividade de 12 meses e setores', defs, css: '', corpo, previa });
}

// ===========================================================================
// 5. RODAPÉ — a nave segue viagem
// ===========================================================================
export function rodape(d, { previa = false } = {}) {
  const W = 1200;
  const H = 220;
  const neb = nebulosa({ w: W, h: H, seed: 121, qtd: 3, prefixo: 'nebR' });
  const css = cssMotor({ ciclo: 11, vx: -340, vy: 60 });

  // os pontos de impacto ficam fora da area do texto (x 380..820)
  const asteroides = [
    { x: 480, y: 50, raio: 11, seed: 61, delay: 1.4, giro: 5 },
    { x: 1400, y: 30, raio: 9, seed: 62, delay: 5.6, giro: 7 },
    { x: 570, y: 140, raio: 8, seed: 64, delay: 8.2, giro: 8 },
    { x: 1320, y: 145, raio: 10, seed: 63, delay: 3.4, giro: 6 },
  ]
    .map((a, i) =>
      asteroideCommit({
        ...a,
        vx: -340,
        vy: 60,
        cor: [PAL.ciano, PAL.roxo2, PAL.rosa, PAL.ambar][i],
        comXP: false,
        fase: previa ? (i === 2 ? 0.39 : 0.16 + i * 0.03) : null,
      })
    )
    .join('');

  const defs = `
    ${neb.defs}
    <linearGradient id="ceuRodape" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#04050d"/><stop offset="100%" stop-color="#080b1e"/>
    </linearGradient>
    ${gradienteTexto('gradRodape', ['#67e8f9', '#a855f7', '#f472b6'])}
    <radialGradient id="veuRodape" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="#05070f" stop-opacity="0.92"/>
      <stop offset="65%" stop-color="#05070f" stop-opacity="0.6"/>
      <stop offset="100%" stop-color="#05070f" stop-opacity="0"/>
    </radialGradient>
    ${fundoVignette(W, H, 'vigRodape')}`;

  const corpo = `
  <rect width="${W}" height="${H}" fill="url(#ceuRodape)"/>
  ${neb.out}
  ${estrelas({ w: W, h: H, seed: 71, qtd: 80 })}
  <rect width="${W}" height="${H}" fill="url(#vigRodape)"/>
  <g transform="translate(1180,58) rotate(-14)">${asteroide(26, 902)}</g>
  <g transform="translate(1064,168) rotate(22)">${asteroide(9, 903)}</g>
  ${asteroides}

  <g transform="translate(48,116)">
    <g class="flutua" style="animation-delay:-2s">
      <g transform="scale(1.55)">${nave(0, 0, 1)}</g>
    </g>
  </g>

  <ellipse cx="600" cy="128" rx="360" ry="88" fill="url(#veuRodape)"/>
  ${txt(600, 74, 13, PAL.fraco, 'FIM DA TRANSMISSÃO', { ancora: 'middle', esp: 6 })}
  ${txt(600, 118, 30, 'url(#gradRodape)', 'OBRIGADO POR JOGAR', { ancora: 'middle', esp: 3.4, peso: 700 })}
  <line x1="430" y1="136" x2="770" y2="136" stroke="${PAL.linha2}" opacity="0.7"/>
  ${txt(600, 160, 10, PAL.fraco, 'O PRÓXIMO COMMIT JÁ ESTÁ NO RADAR', { ancora: 'middle', esp: 2.6, peso: 400 })}
  <g class="cursor">${txt(600, 190, 11, PAL.ciano, '► PRESS START', { ancora: 'middle', esp: 4 })}</g>

  ${scanlines({ w: W, h: H, op: 0.05 })}`;

  return documento({ w: W, h: H, titulo: 'Fim da transmissão — obrigado por jogar', defs, css, corpo, previa });
}
