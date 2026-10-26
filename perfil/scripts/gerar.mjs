#!/usr/bin/env node
// ============================================================================
//  gerar.mjs — monta a arte do perfil a partir dos dados do GitHub
//
//  uso:
//    node scripts/gerar.mjs               # consulta a API (precisa de GITHUB_TOKEN)
//    node scripts/gerar.mjs --offline     # usa data/snapshot.json
//    node scripts/gerar.mjs --previa      # congela as animações no pico do estouro
//    node scripts/gerar.mjs --so=mapa     # gera uma cena específica
// ============================================================================

import { writeFileSync, mkdirSync } from 'node:fs';
import { join } from 'node:path';
import { carregarDados, RAIZ } from './lib/dados.mjs';
import { cabecalho, campo, painelJogador, mapaEstelar, rodape } from './lib/cenas.mjs';

const args = process.argv.slice(2);
const offline = args.includes('--offline');
const previa = args.includes('--previa');
const so = args.find((a) => a.startsWith('--so='))?.split('=')[1];

const CENAS = {
  cabecalho: { fn: cabecalho, arquivo: 'cabecalho.svg' },
  campo: { fn: campo, arquivo: 'campo.svg' },
  painel: { fn: painelJogador, arquivo: 'painel.svg' },
  mapa: { fn: mapaEstelar, arquivo: 'mapa.svg' },
  rodape: { fn: rodape, arquivo: 'rodape.svg' },
};

const SAIDA = join(RAIZ, 'arte');
mkdirSync(SAIDA, { recursive: true });

console.log('🛰️  lendo dados do GitHub…');
const dados = await carregarDados({ offline });
console.log(`   fonte: ${dados.fonte}`);
console.log(`   ${dados.totais.commits} commits · ${dados.totais.contribuicoes} contribuições · nível ${dados.nivel} (${dados.patente.nome}) · ${dados.xp} XP`);

let total = 0;
for (const [nome, cena] of Object.entries(CENAS)) {
  if (so && so !== nome) continue;
  const svg = cena.fn(dados, { previa });
  const destino = join(SAIDA, cena.arquivo);
  writeFileSync(destino, svg, 'utf8');
  total += Buffer.byteLength(svg);
  console.log(`   ✔ arte/${cena.arquivo} (${(Buffer.byteLength(svg) / 1024).toFixed(1)} kB)`);
}
console.log(`✅ pronto — ${(total / 1024).toFixed(1)} kB de SVG`);
