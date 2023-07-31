float drawPoint(vec3 ro,vec3 rd,vec3 p){
  float d=length(cross(p-ro,rd))/length(rd);
  d=smoothstep(.2,.19,d);
  return d;
}

void mainImage(out vec4 fragColor,in vec2 fragCoord){
  vec2 uv=fragCoord.xy/iResolution.xy;
  uv-=.5;
  uv.x*=iResolution.x/iResolution.y;
  
  float t=iTime;
  vec3 ro=vec3(0.,0.,-2);
  vec3 rd=vec3(uv,0.)-ro;
  float d=drawPoint(ro,rd,vec3(sin(t),.3,1.-cos(t)));
  d+=drawPoint(ro,rd,vec3(1.,.4,4));
  fragColor=vec4(d);
}