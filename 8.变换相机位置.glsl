float drawPoint(vec3 ro,vec3 rd,vec3 p){
  float d=length(cross(p-ro,rd))/length(rd);
  d=smoothstep(.06,.05,d);
  return d;
}

void mainImage(out vec4 fragColor,in vec2 fragCoord){
  vec2 uv=fragCoord.xy/iResolution.xy;
  uv-=.5;
  uv.x*=iResolution.x/iResolution.y;
  
  float t=iTime;
  float zoom=1.;
  vec3 lookAt=vec3(.15,.15,.15);
  vec3 ro=vec3(5.*sin(t),4.,-5.*cos(t));
  
  vec3 f=normalize(lookAt-ro);
  vec3 r=normalize(cross(vec3(0,1,0),f));
  vec3 u=cross(f,r);
  
  vec3 rd=zoom*f+uv.x*r+uv.y*u;
  float d=drawPoint(ro,rd,vec3(.0,.0,.0));
  d+=drawPoint(ro,rd,vec3(.3,.0,.0));
  d+=drawPoint(ro,rd,vec3(.3,.0,.3));
  d+=drawPoint(ro,rd,vec3(.0,.0,.3));
  d+=drawPoint(ro,rd,vec3(.0,.3,.0));
  d+=drawPoint(ro,rd,vec3(.3,.3,.0));
  d+=drawPoint(ro,rd,vec3(.0,.3,.3));
  d+=drawPoint(ro,rd,vec3(.3,.3,.3));
  fragColor=vec4(d);
}