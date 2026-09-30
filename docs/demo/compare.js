const form = document.getElementById('seed-form');
const seedInput = document.getElementById('seed');
const versions = ['original','reviewed'];
function seedValue() { return Math.max(0,Math.min(2147483646,Math.trunc(Number(seedInput.value)))); }
function updateLinks() { const seed=seedValue();for(const version of versions) document.getElementById(version+'-open').href=version+'/index.html?seed='+seed; }
seedInput.addEventListener('input',updateLinks);
form.addEventListener('submit',event=>{
  event.preventDefault();if(!form.reportValidity())return;
  updateLinks();
  for(const version of versions){
    const card=document.querySelector('[data-version="'+version+'"]');
    card.querySelector('img').hidden=true;
    const iframe=card.querySelector('iframe');iframe.hidden=false;iframe.src=version+'/index.html?seed='+seedValue();
  }
  document.getElementById('load-status').textContent='두 게임을 불러오는 중입니다. 각 게임을 클릭하고 Enter로 시작하세요.';
});
window.addEventListener('message',event=>{
  if(event.origin!==location.origin||event.data?.type!=='lantern-state')return;
  const data=event.data.data;if(!versions.includes(data?.version))return;
  const frame=document.querySelector('[data-version="'+data.version+'"] iframe');
  if(event.source!==frame.contentWindow)return;
  document.getElementById(data.version+'-stats').textContent=`${data.floor}층 · HP ${data.hp}/${data.maxHp} · ${data.fuel===null?'연료 규칙 없음':'연료 '+data.fuel} · ${data.turns}턴 · seed ${data.seed}`;
  document.getElementById('load-status').textContent='불러온 게임을 클릭하고 Enter로 시작하세요.';
});
let changes=[];
function renderFindings(){
  const query=document.getElementById('search').value.toLocaleLowerCase('ko');
  const rows=changes.filter(row=>(row.id+' '+row.title+' '+row.before+' '+row.after).toLocaleLowerCase('ko').includes(query));
  const root=document.getElementById('findings');root.replaceChildren();
  for(const row of rows){
    const details=document.createElement('details');details.id='change-'+row.id.replace('/','--');
    const summary=document.createElement('summary');const id=document.createElement('b');id.textContent=row.id;summary.append(id,document.createTextNode(row.title));details.append(summary);
    const grid=document.createElement('div');grid.className='detail-grid';
    for(const [heading,value] of [['리뷰 전 · v1',row.before],['리뷰 반영 · v2',row.after]]){const cell=document.createElement('div');const h=document.createElement('h4');h.textContent=heading;const p=document.createElement('p');p.textContent=value;cell.append(h,p);grid.append(cell);}
    const verification=document.createElement('p');verification.className='verify';verification.textContent='구현: '+row.implementation+' / 확인: '+row.verification;
    const link=document.createElement('a');link.href='review-viz.html#'+row.sourceAnchor;link.textContent='기존 리뷰의 이 지적 보기 ↗';
    details.append(grid,verification,link);
    if(row.humanValidationPending){const p=document.createElement('p');p.className='pending';p.textContent='사람의 첫 판 이해도·승률·체험 시간 관찰은 미검증입니다.';details.append(p);}
    root.append(details);
  }
  document.getElementById('finding-count').textContent=`${rows.length} / ${changes.length}개 지적`;
}
document.getElementById('search').addEventListener('input',renderFindings);
fetch('changes.json').then(response=>{if(!response.ok)throw new Error('HTTP '+response.status);return response.json();}).then(data=>{changes=data;renderFindings();}).catch(()=>{document.getElementById('finding-count').textContent='전체 반영표를 불러오지 못했습니다. 정적 HTTP 서버에서 열거나 저장소의 review-response.md를 확인하세요.';});
