// ============================================================================
//  motor.mjs — o motor do campo de asteroides
//  Cada asteroide = 1 commit. Ele entra em cena, atravessa o setor e, ao ser
//  atingido, estoura em blocos e lascas (+XP). CSS/SVG puro, em loop infinito.
// ============================================================================

import { PAL, asteroide, n } from './svg.mjs';
import { REGRAS } from './dados.mjs';

// vetor do estilhaço: [x, y, giro, tamanho(0..1), tipo(0 bloco | 1 lasca | 2 pedra)]
const DIRECOES = [
  [48, -60, 150, 1.0, 0],
  [20, -84, 90, 0.7, 1],
  [-44, -62, -140, 0.95, 2],
  [-80, -18, -95, 0.85, 0],
  [-56, 46, 60, 1.0, 2],
  [-2, 72, 130, 0.66, 1],
  [60, 44, -60, 0.9, 0],
  [84, 4, 210, 0.7, 2],
  [-28, 82, 45, 0.85, 1],
  [46, -14, -190, 0.62, 0],
  [34, 62, 70, 0.7, 2],
  [-64, -32, -45, 0.9, 0],
];

const FASE_VOO = 34; // % do ciclo em que o asteroide colide
const FIM_ESTOURO = 60; // % do ciclo em que os estilhaços somem

/** descrição dos pedaços de uma explosão (usada pelo modo animado e pelo congelado) */
function estilhacos(raio, cor) {
  return DIRECOES.map(([tx, ty, rot, tam, tipo], i) => {
    const base = Math.max(5.2, raio * 0.78 * (0.66 + tam * 0.5));
    const corBloco = tipo === 1 ? (i % 2 ? '#ffffff' : cor) : i % 5 === 0 ? cor : i % 5 === 1 ? PAL.ambar : PAL.pedraA;
    let w, h, forma = 'rect';
    if (tipo === 0) {
      w = base * (i % 3 === 0 ? 1 : 1.4);
      h = base * (i % 3 === 0 ? 1 : 0.6);
    } else if (tipo === 1) {
      w = base * 0.3;
      h = base * 1.55;
    } else {
      w = base * 1.05;
      h = base * 0.95;
      forma = 'pedra';
    }
    return { tx, ty, rot, tam, tipo, base, cor: corBloco, w, h, forma, i };
  });
}

function desenharEstilhaco(e, { alpha = 1, escala = 1, deslocamento = 1, girado = 1 } = {}) {
  const tr = `translate(${n(e.tx * deslocamento)},${n(e.ty * deslocamento)}) rotate(${n(e.rot * girado)}) scale(${n(escala)})`;
  const op = n(Math.max(0, alpha));
  if (e.forma === 'pedra') {
    return `<path d="M${n(-e.w / 2)} ${n(-e.h * 0.2)} L${n(-e.w * 0.15)} ${n(-e.h / 2)} L${n(e.w / 2)} ${n(-e.h * 0.3)} L${n(e.w * 0.35)} ${n(e.h / 2)} L${n(-e.w * 0.4)} ${n(e.h * 0.42)} Z" fill="${e.cor}" opacity="${op}" transform="${tr}"/>`;
  }
  return `<rect x="${n(-e.w / 2)}" y="${n(-e.h / 2)}" width="${n(e.w)}" height="${n(e.h)}" fill="${e.cor}" opacity="${op}"${e.forma === 'rect' && e.tipo === 1 ? ' rx="1"' : ''} transform="${tr}"/>`;
}

/** keyframes compartilhados por todos os asteroides da cena */
export function cssMotor({ ciclo = 9, vx = -300, vy = 70 } = {}) {
  const qtd = DIRECOES.length;
  let css = `
  @keyframes voo {
    0%   { opacity: 0; transform: translate(0px, 0px); }
    4%   { opacity: 0; transform: translate(0px, 0px); }
    7%   { opacity: 1; }
    ${FASE_VOO - 0.4}% { opacity: 1; transform: translate(${n(vx)}px, ${n(vy)}px); }
    ${FASE_VOO}%     { opacity: 0; transform: translate(${n(vx)}px, ${n(vy)}px); }
    100% { opacity: 0; transform: translate(${n(vx)}px, ${n(vy)}px); }
  }
  @keyframes girarAsteroide { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
  @keyframes ondaChoque {
    0%, ${FASE_VOO - 0.4}% { opacity: 0; stroke-width: 4; }
    ${FASE_VOO}%   { opacity: .85; stroke-width: 2.6; }
    ${FASE_VOO + 16}% { opacity: 0; stroke-width: .3; }
    100% { opacity: 0; stroke-width: .3; }
  }
  @keyframes flash {
    0%, ${FASE_VOO - 0.2}% { opacity: 0; }
    ${FASE_VOO}%   { opacity: .8; }
    ${FASE_VOO + 1.6}% { opacity: 0; }
    100% { opacity: 0; }
  }
  @keyframes subirXP {
    0%, ${FASE_VOO - 0.2}% { opacity: 0; transform: translate(0, 6px); }
    ${FASE_VOO + 1.5}% { opacity: 1; transform: translate(0, -2px); }
    ${FASE_VOO + 16}% { opacity: 0; transform: translate(0, -32px); }
    100% { opacity: 0; transform: translate(0, -32px); }
  }
  .voo { animation: voo ${ciclo}s linear infinite; animation-delay: var(--d, 0s); }
  .gira { animation: girarAsteroide var(--giro, 6s) linear infinite; transform-box: fill-box; transform-origin: center; }
  .onda { animation: ondaChoque ${ciclo}s linear infinite; animation-delay: var(--d, 0s); transform-box: fill-box; transform-origin: center; }
  .flash { animation: flash ${ciclo}s linear infinite; animation-delay: var(--d, 0s); }
  .xpTxt { animation: subirXP ${ciclo}s linear infinite; animation-delay: var(--d, 0s); }
  .estouro .b { animation-duration: ${ciclo}s; animation-timing-function: cubic-bezier(.16,.72,.32,1); animation-iteration-count: infinite; animation-delay: var(--d, 0s); transform-box: fill-box; transform-origin: center; }
  `;

  for (let i = 0; i < qtd; i++) {
    css += `.estouro .b${i} { animation-name: b${i}; }\n`;
  }
  for (let i = 0; i < qtd; i++) {
    const [tx, ty, rot] = DIRECOES[i];
    css += `
  @keyframes b${i} {
    0%, ${FASE_VOO - 0.3}% { opacity: 0; transform: translate(0, 0) rotate(0deg) scale(1.35); }
    ${FASE_VOO}% { opacity: 1; transform: translate(0, 0) rotate(0deg) scale(1.1); }
    ${FASE_VOO + 9}% { opacity: 1; transform: translate(${n(tx * 0.6)}px, ${n(ty * 0.6)}px) rotate(${n(rot * 0.5)}deg) scale(.95); }
    ${FIM_ESTOURO}% { opacity: 0; transform: translate(${n(tx)}px, ${n(ty)}px) rotate(${rot}deg) scale(.3); }
    100% { opacity: 0; transform: translate(${n(tx)}px, ${n(ty)}px) rotate(${rot}deg) scale(.3); }
  }`;
  }
  return css;
}

/**
 * Um asteroide = um commit.
 * Grupo 1: a pedra viajando. Grupo 2: o estouro no ponto de impacto.
 * `fase` (0..1) congela a cena naquele instante — útil para inspeção/preview.
 */
export function asteroideCommit({
  x,
  y,
  raio = 16,
  seed = 1,
  delay = 0,
  cor = PAL.ciano,
  vx = -300,
  vy = 70,
  comXP = true,
  giro = 6,
  fase = null,
}) {
  const d = -delay;

  // rastro de velocidade (pedra "borrada" atrás)
  let rastro = '';
  for (let i = 1; i <= 3; i++) {
    const f = i / 4;
    rastro += `<circle cx="${n(vx * 0.02 * f)}" cy="${n(-vy * 0.02 * f)}" r="${n(raio * (1 - f * 0.3))}" fill="${cor}" opacity="${n(0.09 - f * 0.02)}"/>`;
  }

  const pedacos = estilhacos(raio, cor);

  // poeira fina que sobra no ponto do impacto
  const poeira = Array.from({ length: 8 }, (_, i) => {
    const a = (i / 8) * Math.PI * 2 + 0.3;
    const dist = raio * (1.0 + (i % 3) * 0.45);
    return { a, dist, r: 1.4 + (i % 3) * 0.8, i };
  });

  const pedra = (extra = '') => `<g${extra}>
      ${rastro}
      <circle r="${n(raio * 1.5)}" fill="${cor}" opacity="0.06"/>
      <circle r="${n(raio * 1.22)}" fill="none" stroke="${cor}" stroke-width="0.7" opacity="0.1"/>
      ${asteroide(raio, seed)}
    </g>`;

  // ------------------------------------------------ modo congelado
  if (fase != null) {
    const f = ((fase % 1) + 1) % 1;
    const P = FASE_VOO / 100;
    const px = n(x + vx * Math.min(f / P, 1));
    const py = n(y + vy * Math.min(f / P, 1));
    if (f < P) {
      const op = f < 0.04 ? 0 : f < 0.07 ? (f - 0.04) / 0.03 : 1;
      return `<g transform="translate(${px},${py})" opacity="${n(op)}"><g class="gira">${pedra()}</g></g>`;
    }
    const g = (f - P) / (FIM_ESTOURO / 100 - P);
    if (g > 1) return '';
    const ea = 1 - Math.pow(1 - Math.min(g / 0.8, 1), 2);
    const alpha = Math.max(0, 1 - Math.pow(Math.max(0, g - 0.45) / 0.55, 1.3));
    const corpo = pedacos.map((e) => desenharEstilhaco(e, { alpha, escala: 1 - 0.7 * ea, deslocamento: ea, girado: ea })).join('');
    const poeiraSvg = poeira
      .map((p) => `<circle cx="${n(Math.cos(p.a) * p.dist * (0.4 + ea * 1.4))}" cy="${n(Math.sin(p.a) * p.dist * (0.4 + ea * 1.4))}" r="${n(p.r)}" fill="${PAL.pedraA}" opacity="${n(alpha * 0.55)}"/>`)
      .join('');
    const opFlash = g < 0.1 ? 0.85 * (1 - g / 0.1) : 0;
    return `<g transform="translate(${px},${py})">
      ${opFlash ? `<circle r="${n(raio * 0.62)}" fill="#ffffff" opacity="${n(opFlash)}"/>` : ''}
      <circle r="${n(raio * 1.1 + raio * 2.1 * ea)}" fill="none" stroke="${cor}" stroke-width="${n(2.6 * (1 - ea) + 0.25)}" opacity="${n(0.9 * (1 - ea))}"/>
      ${corpo}${poeiraSvg}
      ${comXP && g > 0.02 && g < 0.85 ? `<text x="0" y="${n(-raio - 16 - 26 * g)}" font-family="Courier New, monospace" font-size="11.5" font-weight="700" fill="${PAL.ambar}" text-anchor="middle" letter-spacing="1" opacity="${n(1 - g / 0.85)}">+${REGRAS.xpPorCommit} XP</text>` : ''}
    </g>`;
  }

  // ------------------------------------------------ modo animado
  return `<g class="voo" style="--d:${d}s">
    <g transform="translate(${n(x)},${n(y)})">
      <g class="gira" style="--giro:${giro}s">
        ${rastro}
        <circle r="${n(raio * 1.5)}" fill="${cor}" opacity="0.06"/>
        <circle r="${n(raio * 1.22)}" fill="none" stroke="${cor}" stroke-width="0.7" opacity="0.1"/>
        ${asteroide(raio, seed)}
      </g>
    </g>
  </g>
  <g class="estouro" style="--d:${d}s" transform="translate(${n(x + vx)},${n(y + vy)})">
    <circle class="flash" r="${n(raio * 0.62)}" fill="#ffffff" opacity="0"/>
    <circle class="onda" r="${n(raio * 1.15)}" fill="none" stroke="${cor}" opacity="0"/>
    <circle class="onda" r="${n(raio * 1.15)}" fill="none" stroke="#ffffff" opacity="0" style="animation-delay:${n(d + 0.16)}s"/>
    ${pedacos.map((e) => `<g class="b b${e.i}" opacity="0">${desenharEstilhaco(e, { alpha: 1 })}</g>`).join('')}
    ${poeira.map((p) => `<circle class="b b${p.i}" cx="${n(Math.cos(p.a) * p.dist)}" cy="${n(Math.sin(p.a) * p.dist)}" r="${n(p.r)}" fill="${PAL.pedraA}" opacity="0"/>`).join('')}
    ${comXP ? `<text class="xpTxt" x="0" y="${n(-raio - 16)}" font-family="Courier New, monospace" font-size="11.5" font-weight="700" fill="${PAL.ambar}" text-anchor="middle" letter-spacing="1" opacity="0">+${REGRAS.xpPorCommit} XP</text>` : ''}
  </g>`;
}

/** cinturão de fundo: um asteroide pequeno para cada commit */
export function cinturao({ qtd, caixa, seed = 42, max = 46, cor = '#3c4763' }) {
  const { x, y, w, h } = caixa;
  let out = '';
  const total = Math.min(qtd, max);
  for (let i = 0; i < total; i++) {
    const gx = ((i * 7 + 3) % 13) / 13;
    const gy = ((i * 11 + 5) % 17) / 17;
    const px = x + 30 + ((gx + (i % 3) * 0.07) % 1) * (w - 70);
    const py = y + 26 + ((gy + (i % 5) * 0.05) % 1) * (h - 60);
    const r = 2.4 + ((i * 13) % 7) * 0.7;
    const op = 0.22 + ((i * 17) % 9) * 0.05;
    out += `<g transform="translate(${n(px)},${n(py)})" opacity="${n(op)}">
      <path d="M${n(-r)} 0 L${n(-r * 0.4)} ${n(-r)} L${n(r * 0.8)} ${n(-r * 0.7)} L${n(r)} ${n(r * 0.3)} L${n(r * 0.2)} ${n(r)} L${n(-r * 0.9)} ${n(r * 0.5)} Z" fill="${cor}"/>
    </g>`;
  }
  return out;
}
