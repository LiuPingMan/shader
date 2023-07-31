float hexagonDist(vec2 uv){
  uv=abs(uv);
  vec3 col=vec3(0.);
  float d=dot(uv,normalize(vec2(1.,1.73)));
  d=max(d,uv.x);
  return d;
}

vec4 hexagonCoord(vec2 uv){
  uv*=10.;
  vec2 r=vec2(1.,1.73);
  vec2 h=r/2.;
  vec2 a=mod(uv,r)-h;
  vec2 b=mod(uv-h,r)-h;
  vec2 gv=length(a)<length(b)?a:b;
  vec2 id=uv-gv;
  float x=floor((atan(gv.x,gv.y)+3.1415)/3.1415*3.)/6.;
  float y=hexagonDist(gv);
  return vec4(x,y,id.x,id.y);
}

void mainImage(out vec4 fragColor,in vec2 fragCoord){
  vec2 uv=(fragCoord-.5*iResolution.xy)/iResolution.y;
  vec3 col=vec3(0.);
  
  vec4 hc=hexagonCoord(uv);
  float c=smoothstep(.05,.1,(.5-hc.y)*sin(hc.z*hc.w+iTime));
  col+=c;
  fragColor=vec4(col,1.);
}