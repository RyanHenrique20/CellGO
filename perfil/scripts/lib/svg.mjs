// ============================================================================
//  svg.mjs — primitivas visuais do "SPACE ARCADE" do perfil
//  Tudo aqui e' SVG puro, sem dependencia externa, para renderizar direto
//  no <img> do GitHub (que aceita CSS e animacoes, mas nao aceita JS).
// ============================================================================

export const PAL = {
  bg0: '#04050d',
  bg1: '#0a0c1e',
  bg2: '#0d1128',
  linha: '#1b2340',
  linha2: '#2a3557',
  painel: '#070a18',
  texto: '#dbe4ff',
  fraco: '#7c88ad',
  fraco2: '#4d5878',
  ciano: '#22d3ee',
  ciano2: '#67e8f9',
  roxo: '#8b5cf6',
  roxo2: '#a855f7',
  rosa: '#f472b6',
  ambar: '#fbbf24',
  verde: '#34d399',
  vermelho: '#fb7185',
  pedraA: '#8d99ba',
  pedraB: '#4b5675',
  pedraC: '#1e263c',
};

export const FONTE = 'Courier New, ui-monospace, SFMono-Regular, Menlo, monospace';

// tipo de commit -> cor
export const CORES_TIPO = {
  feat: PAL.ciano,
  fix: PAL.ambar,
  docs: PAL.roxo2,
  merge: PAL.verde,
  refactor: PAL.rosa,
  chore: PAL.fraco,
  outro: PAL.texto,
};

// ---------------------------------------------------------------------------
// utilidades
// ---------------------------------------------------------------------------

/** RNG deterministico (mulberry32): mesmo seed => mesmo desenho sempre. */
export function rng(seed = 1) {
  let a = seed >>> 0;
  return () => {
    a |= 0;
    a = (a + 0x6d2b79f5) | 0;
    let t = Math.imul(a ^ (a >>> 15), 1 | a);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

export const esc = (s) =>
  String(s)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');

export const n = (v) => Math.round(v * 100) / 100;
export const clamp = (v, a, b) => Math.max(a, Math.min(b, v));
export const entre = (r, a, b) => a + r() * (b - a);
export const escolha = (r, arr) => arr[Math.floor(r() * arr.length) % arr.length];

/** texto monoespaçado */
export function txt(x, y, size, fill, conteudo, o = {}) {
  const {
    peso = 700,
    ancora = 'start',
    esp = 0,
    op = 1,
    cls = '',
    id = '',
    estilo = '',
  } = o;
  const partes = [];
  if (x != null) partes.push(`x="${n(x)}"`);
  if (y != null) partes.push(`y="${n(y)}"`);
  partes.push(`font-family="${FONTE}"`);
  partes.push(`font-size="${size}"`);
  partes.push(`font-weight="${peso}"`);
  partes.push(`fill="${fill}"`);
  if (ancora !== 'start') partes.push(`text-anchor="${ancora}"`);
  if (esp) partes.push(`letter-spacing="${esp}"`);
  if (op !== 1) partes.push(`opacity="${op}"`);
  if (cls) partes.push(`class="${cls}"`);
  if (id) partes.push(`id="${id}"`);
  if (estilo) partes.push(`style="${estilo}"`);
  return `<text ${partes.join(' ')}>${esc(conteudo)}</text>`;
}

// ---------------------------------------------------------------------------
// ceu
// ---------------------------------------------------------------------------

/** campo de estrelas; ~1 a cada 4 pisca */
export function estrelas({ w, h, seed = 7, qtd = 90, x0 = 0, y0 = 0, brilho = 0 }) {
  const r = rng(seed);
  const cores = ['#ffffff', '#cfe3ff', '#a5b4fc', '#67e8f9', '#f0abfc', '#fde68a'];
  let out = '';
  for (let i = 0; i < qtd; i++) {
    const x = n(x0 + r() * w);
    const y = n(y0 + r() * h);
    const rad = n(0.35 + r() * (brilho ? 1.9 : 1.3));
    const cor = cores[Math.floor(r() * cores.length)];
    const op = n(0.18 + r() * 0.62);
    if (r() < 0.26) {
      const dur = n(2.4 + r() * 4.6);
      const delay = n(-r() * 7);
      out += `<circle class="pisca" cx="${x}" cy="${y}" r="${rad}" fill="${cor}" opacity="${op}" style="animation-duration:${dur}s;animation-delay:${delay}s"/>`;
    } else {
      out += `<circle cx="${x}" cy="${y}" r="${rad}" fill="${cor}" opacity="${op}"/>`;
    }
  }
  return out;
}

/** manchas de nebulosa (gradientes radiais empilhados) */
export function nebulosa({ w, h, seed = 3, qtd = 4, cores = [PAL.roxo, PAL.ciano, PAL.rosa], prefixo = 'neb' }) {
  const r = rng(seed);
  let defs = '';
  let out = '';
  for (let i = 0; i < qtd; i++) {
    const id = `${prefixo}${i}`;
    const cor = cores[i % cores.length];
    const cx = n(r() * w);
    const cy = n(r() * h);
    const rx = n(w * (0.16 + r() * 0.26));
    const ry = n(h * (0.28 + r() * 0.45));
    const op = n(0.1 + r() * 0.14);
    defs += `<radialGradient id="${id}" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="${cor}" stop-opacity="${op}"/>
      <stop offset="55%" stop-color="${cor}" stop-opacity="${n(op * 0.4)}"/>
      <stop offset="100%" stop-color="${cor}" stop-opacity="0"/>
    </radialGradient>`;
    out += `<ellipse cx="${cx}" cy="${cy}" rx="${rx}" ry="${ry}" fill="url(#${id})"/>`;
  }
  return { defs, out };
}

/** estrias horizontais de monitor antigo */
export function scanlines({ w, h, op = 0.055, passo = 3, cor = '#000000' }) {
  return `<rect x="0" y="0" width="${w}" height="${h}" fill="url(#scan-${passo})" opacity="${op}"/>
  <defs><pattern id="scan-${passo}" width="4" height="${passo}" patternUnits="userSpaceOnUse">
    <rect width="4" height="1" fill="${cor}"/></pattern></defs>`;
}

/** estrela cadente / rastro rápido */
export function rastro(x, y, comp = 90, ang = 24, cor = PAL.ciano, op = 0.7, cls = '') {
  const rad = (ang * Math.PI) / 180;
  const dx = Math.cos(rad) * comp;
  const dy = Math.sin(rad) * comp;
  return `<line class="${cls}" x1="${n(x)}" y1="${n(y)}" x2="${n(x + dx)}" y2="${n(y + dy)}" stroke="${cor}" stroke-width="2" stroke-linecap="round" opacity="${op}" fill="none"/>`;
}

// ---------------------------------------------------------------------------
// asteroides
// ---------------------------------------------------------------------------

/** poligono irregular com cara de pedra espacial */
export function asteroidePath(raio, seed, lados = 11) {
  const r = rng(seed);
  const pts = [];
  for (let i = 0; i < lados; i++) {
    const a = (i / lados) * Math.PI * 2 + (r() - 0.5) * 0.24;
    const rr = raio * (0.73 + r() * 0.3);
    pts.push([n(Math.cos(a) * rr), n(Math.sin(a) * rr)]);
  }
  return `M${pts.map((p) => p.join(' ')).join('L')}Z`;
}

/**
 * asteroide completo: pedra em camadas (sombra -> corpo -> luz) + crateras.
 * A tecnica das camadas escaladas é o que dá a leitura de "rocha" em pixel art.
 */
export function asteroide(raio, seed, { cor = PAL.pedraB, luz = PAL.pedraA, escuro = PAL.pedraC } = {}) {
  const r = rng(seed + 99);
  const d = asteroidePath(raio, seed, 9 + Math.floor(r() * 3));

  const camada = (escala, dx, dy, fill, op = 1) =>
    `<path d="${d}" fill="${fill}" opacity="${op}" transform="translate(${n(dx)},${n(dy)}) scale(${escala})"/>`;

  let crateras = '';
  const qtd = 2 + Math.floor(r() * 3);
  for (let i = 0; i < qtd; i++) {
    const a = r() * Math.PI * 2;
    const dist = raio * (0.15 + r() * 0.42);
    const cx = Math.cos(a) * dist;
    const cy = Math.sin(a) * dist;
    const cr = raio * (0.11 + r() * 0.15);
    crateras += `<circle cx="${n(cx)}" cy="${n(cy)}" r="${n(cr)}" fill="${escuro}" opacity="0.8"/>
      <path d="M${n(cx - cr * 0.9)} ${n(cy)} A ${n(cr * 0.9)} ${n(cr * 0.9)} 0 0 1 ${n(cx)} ${n(cy - cr * 0.9)}" fill="none" stroke="${luz}" stroke-width="${n(Math.max(0.8, raio * 0.09))}" opacity="0.55"/>`;
  }

  return `<g class="pedra">
    ${camada(1, 0, 0, escuro)}
    ${camada(0.9, -raio * 0.02, -raio * 0.03, cor)}
    <g clip-path="url(#pedra-${seed})">
      ${camada(0.56, -raio * 0.2, -raio * 0.22, luz, 0.9)}
      ${crateras}
    </g>
    <clipPath id="pedra-${seed}"><path d="${d}" transform="scale(0.9)"/></clipPath>
  </g>`;
}

/** bloco de detrito (quadrado, estilo voxel) */
export function bloco(dir, cor, tam = 6) {
  return `<rect class="b b${dir}" x="${n(-tam / 2)}" y="${n(-tam / 2)}" width="${tam}" height="${tam}" fill="${cor}"/>`;
}

/** nave pixel-art (aponta para cima) */
export function nave(x, y, s = 1, { corpo = '#e2e8ff', asa = PAL.ciano, chama = PAL.ambar } = {}) {
  return `<g transform="translate(${n(x)},${n(y)}) scale(${s})">
    <path d="M0 -16 L4 -6 L12 8 L6 8 L4 3 L0 12 L-4 3 L-6 8 L-12 8 L-4 -6 Z" fill="${asa}" opacity="0.9"/>
    <path d="M0 -16 L4 -4 L4 8 L-4 8 L-4 -4 Z" fill="${corpo}"/>
    <rect x="-2" y="-2" width="4" height="4" fill="${PAL.bg0}"/>
    <rect x="-4" y="8" width="8" height="3" fill="${PAL.ciano2}" opacity="0.8"/>
    <path class="chama" d="M-3 11 L0 22 L3 11 Z" fill="${chama}"/>
    <path class="chama2" d="M-1.5 11 L0 17 L1.5 11 Z" fill="#fff8dc"/>
  </g>`;
}

// ---------------------------------------------------------------------------
// molduras, paineis e HUD
// ---------------------------------------------------------------------------

export function cantos(x, y, w, h, cor = PAL.linha2, tam = 14, esp = 2) {
  const t = tam;
  const s = esp;
  return `<g stroke="${cor}" stroke-width="${s}" fill="none" stroke-linecap="square">
    <path d="M${x} ${y + t} L${x} ${y} L${x + t} ${y}"/>
    <path d="M${x + w - t} ${y} L${x + w} ${y} L${x + w} ${y + t}"/>
    <path d="M${x + w} ${y + h - t} L${x + w} ${y + h} L${x + w - t} ${y + h}"/>
    <path d="M${x + t} ${y + h} L${x} ${y + h} L${x} ${y + h - t}"/>
  </g>`;
}

export function painel(x, y, w, h, o = {}) {
  const {
    raio = 8,
    fill = 'rgba(7,10,24,0.72)',
    borda = PAL.linha,
    corCanto = PAL.linha2,
    tam = 14,
    brilho = false,
  } = o;
  return `<g>
    <rect x="${x}" y="${y}" width="${w}" height="${h}" rx="${raio}" fill="${fill}" stroke="${borda}" stroke-width="1.2"/>
    ${brilho ? `<rect x="${x + 1}" y="${y + 1}" width="${w - 2}" height="${h - 2}" rx="${raio}" fill="url(#veu-brilho)" opacity="0.5"/>` : ''}
    ${cantos(x, y, w, h, corCanto, tam)}
  </g>`;
}

/** barra segmentada estilo arcade */
export function barra(x, y, w, h, pct, { cor = PAL.ciano, fundo = '#101729', bloco = 5, gap = 3 } = {}) {
  const total = Math.max(1, Math.floor((w + gap) / (bloco + gap)));
  const acesos = Math.round(total * clamp(pct, 0, 1));
  let out = `<rect x="${x}" y="${y}" width="${w}" height="${h}" fill="${fundo}" rx="1"/>`;
  for (let i = 0; i < total; i++) {
    const bx = x + i * (bloco + gap);
    if (i < acesos) {
      out += `<rect x="${n(bx)}" y="${y}" width="${bloco}" height="${h}" fill="${cor}" opacity="${i === acesos - 1 ? 1 : 0.85}"/>`;
    } else {
      out += `<rect x="${n(bx)}" y="${y}" width="${bloco}" height="${h}" fill="#1d2740" opacity="0.7"/>`;
    }
  }
  return out;
}

/** titulo de secao no estilo "barra de HUD" */
export function tituloSecao(x, y, w, texto, { cor = PAL.ciano, sub = '', alinhamento = 'esq' } = {}) {
  const tr = alinhamento === 'dir';
  return `<g>
    <rect x="${x}" y="${y - 14}" width="4" height="18" fill="${cor}"/>
    <rect x="${x + 8}" y="${y - 12}" width="${tr ? 0 : 18}" height="2" fill="${cor}" opacity="0.6"/>
    ${txt(x + 12, y, 13, PAL.texto, texto, { esp: 3.2 })}
    ${sub ? txt(x + w, y, 10, PAL.fraco, sub, { ancora: 'end', esp: 1.6, peso: 400 }) : ''}
  </g>`;
}

// ---------------------------------------------------------------------------
// documento
// ---------------------------------------------------------------------------

const CSS_BASE = `
  .pisca { animation: piscar 3s ease-in-out infinite; }
  @keyframes piscar { 0%, 100% { opacity: 1; } 50% { opacity: .2; } }
  .chama { animation: queimar .22s steps(2, end) infinite; transform-origin: 0 11px; }
  @keyframes queimar { 0% { transform: scaleY(1); opacity: 1; } 100% { transform: scaleY(.55); opacity: .7; } }
  .chama2 { animation: queimar .17s steps(2, end) infinite; }
  .cursor { animation: piscarC 1.05s steps(2, end) infinite; }
  @keyframes piscarC { 0%, 49% { opacity: 1; } 50%, 100% { opacity: 0; } }
  .flutua { animation: flutuar 6s ease-in-out infinite; }
  @keyframes flutuar { 0%, 100% { transform: translateY(0); } 50% { transform: translateY(-6px); } }
`;

export function documento({ w, h, titulo, defs = '', css = '', corpo, previa = false }) {
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${w}" height="${h}" viewBox="0 0 ${w} ${h}" role="img" aria-label="${esc(titulo)}">
<title>${esc(titulo)}</title>
<!-- cena gerada automaticamente a partir dos dados publicos do GitHub -->
<defs>
  ${defs}
</defs>
<style><![CDATA[
  ${CSS_BASE}
  ${css}
]]></style>
${corpo}
</svg>`;
}

export const fundoVignette = (w, h, id = 'vig') => `<radialGradient id="${id}" cx="50%" cy="46%" r="78%">
  <stop offset="55%" stop-color="#000000" stop-opacity="0"/>
  <stop offset="100%" stop-color="#000000" stop-opacity="0.55"/>
</radialGradient>`;

export const gradienteTexto = (id, cores, ang = 0) =>
  `<linearGradient id="${id}" x1="0" y1="0" x2="${ang ? 0 : 1}" y2="${ang ? 1 : 0}">
    ${cores.map((c, i) => `<stop offset="${n((i / (cores.length - 1)) * 100)}%" stop-color="${c}"/>`).join('')}
  </linearGradient>`;

export const glow = (id, desvio = 3.4) => `<filter id="${id}" x="-40%" y="-40%" width="180%" height="180%">
  <feGaussianBlur stdDeviation="${desvio}" result="b"/>
  <feMerge><feMergeNode in="b"/><feMergeNode in="b"/><feMergeNode in="SourceGraphic"/></feMerge>
</filter>`;
