#!/usr/bin/env node
// ============================================================================
//  sincronizar.mjs — busca os dados frescos do GitHub, salva o snapshot e
//  redesenha todas as cenas. É o que o GitHub Actions roda todo dia.
// ============================================================================

import { writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { buscarGitHub, paraSnapshot, carregarDados, RAIZ } from './lib/dados.mjs';
import { cabecalho, campo, painelJogador, mapaEstelar, rodape } from './lib/cenas.mjs';

const LOGIN = process.env.GH_LOGIN || 'RyanHenrique20';
const TOKEN = process.env.GITHUB_TOKEN;

if (!TOKEN) {
  console.error('✖ defina GITHUB_TOKEN no ambiente.');
  process.exit(1);
}

console.log(`🛰️  consultando o GitHub (@${LOGIN})…`);
const bruto = await buscarGitHub(LOGIN, TOKEN);
const snapshot = paraSnapshot(bruto);

writeFileSync(join(RAIZ, 'data', 'snapshot.json'), JSON.stringify(snapshot, null, 2) + '\n', 'utf8');
console.log(`   snapshot salvo: ${snapshot.totais.commits} commits · ${snapshot.totais.contribuicoes} contribuições`);

const dados = await carregarDados({ offline: true });
const cenas = { cabecalho, campo, painel: painelJogador, mapa: mapaEstelar, rodape };
for (const [nome, fn] of Object.entries(cenas)) {
  const svg = fn(dados, { previa: false });
  writeFileSync(join(RAIZ, 'arte', `${nome}.svg`), svg, 'utf8');
  console.log(`   ✔ arte/${nome}.svg (${(Buffer.byteLength(svg) / 1024).toFixed(1)} kB)`);
}
console.log('✅ arte atualizada.');
