void mainImage(out vec4 fragColor,in vec2 fragCoord){
  vec2 uv=(2.*fragCoord-iResolution.xy)/iResolution.y;
  uv=vec2(atan(uv.x,uv.y)/6.283+.5,length(uv));
  float t=iTime;
  float x=uv.x*5.;
  float m=min(fract(x),fract(1.-x));
  float c=smoothstep(0.,.02,m*.3+.2-uv.y);
  fragColor=vec4(c);
}