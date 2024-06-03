void mainImage(out vec4 fragColor,in vec2 fragCoord){
  vec2 uv=(2.*fragCoord-iResolution.xy)/iResolution.y;
  
  float star=max(0.,1.-abs(uv.x*uv.y*1000.));
  
  fragColor=vec4(vec3(star),1.);
}