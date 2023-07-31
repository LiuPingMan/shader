void mainImage(out vec4 fragColor,in vec2 fragCoord){
  vec2 uv=(2.*fragCoord-iResolution.xy)/iResolution.y;
  vec2 m=iMouse.xy/iResolution.xy;
  float zoom=pow(10.,-m.x*6.);
  vec2 c=uv*zoom*5.;
  c+=vec2(-.626,.458);
  vec2 z=vec2(0.);
  float iter=0.;
  const float max_iter=1000.;
  for(float i=0.;i<max_iter;i++){
    z=vec2(z.x*z.x-z.y*z.y,2.*z.x*z.y)+c;
    if(length(z)>2.)break;
    iter++;
  }
  float f=iter/max_iter;
  vec3 col=vec3(f);
  fragColor=vec4(col,1.);
}