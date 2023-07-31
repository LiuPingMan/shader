vec3 drawGrid(vec2 uv){
  vec3 color=vec3(0.);
  vec2 subdivision=fract(uv);
  color+=vec3(1.-step(fwidth(uv.x),abs(subdivision.x)));
  color+=vec3(1.-step(fwidth(uv.y),abs(subdivision.y)));
  color+=vec3(1.-step(fwidth(uv.x),abs(uv.x)),0.,0.);
  color+=vec3(0.,1.-step(fwidth(uv.y),abs(uv.y)),0.);
  if(color.x>1.){
    color-=vec3(1.);
  }
  if(color.y>1.){
    color-=vec3(1.);
  }
  return color;
}

void mainImage(out vec4 fragColor,in vec2 fragCoord){
  vec2 uv=3.*(2.*fragCoord.xy-iResolution.xy)/min(iResolution.x,iResolution.y);
  vec3 color=drawGrid(uv);
  fragColor=vec4(color,1.);
}