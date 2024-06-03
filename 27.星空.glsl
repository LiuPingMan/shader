#define PI 3.1415
#define MAX_LAYER 5.

mat2 Rot(float angle){
  float s=sin(angle);
  float c=cos(angle);
  return mat2(c,-s,s,c);
}

float Star(vec2 uv,float flare){
  float len=length(uv);
  float c=.04/len;
  float s=max(0.,1.-abs(uv.x*uv.y*1000.));
  c+=s*flare;
  uv=uv*Rot(PI/4.);
  float s1=max(0.,1.-abs(uv.x*uv.y*1000.));
  c+=s1*flare*.25;
  c=c*smoothstep(.8,.2,len);
  return c;
}

float Hash21(vec2 p){
  p=fract(p*vec2(123.45,456.21));
  p+=dot(p,p+45.32);
  return fract(p.x*p.y);
}

vec3 Layer(vec2 uv){
  vec3 col=vec3(0.);
  vec2 id=floor(uv);
  uv=fract(uv)-.5;
  
  for(int y=-1;y<=1;y++){
    for(int x=-1;x<=1;x++){
      vec2 neighborOffset=vec2(x,y);
      float n=Hash21(id+neighborOffset);
      vec2 innerOffset=vec2(n-.5,fract(n*52.)-.5);
      float size=fract(n*345.34)*.8+.2;
      float flare=smoothstep(.8,.9,size);
      float star=Star(uv-neighborOffset-innerOffset,flare);
      vec3 color=sin(vec3(.2,.5,.9)*fract(n*2345.2)*6.28)*.5+.5;
      color*=vec3(.3+size*.2,.5,.5+size*1.5);
      
      col+=star*size*color;
    }
  }
  return col;
}

void mainImage(out vec4 fragColor,in vec2 fragCoord){
  vec2 uv=(2.*fragCoord-iResolution.xy)/iResolution.y;
  float t=iTime*.1;
  uv*=Rot(t);
  vec3 col=vec3(0.);
  for(float i=0.;i<1.;i+=1./MAX_LAYER){
    float depth=fract(i+t);
    float fade=smoothstep(0.,.3,depth)*smoothstep(1.,.9,depth);
    float scale=mix(20.,.5,depth);
    col+=Layer(uv*scale+i*435.32)*fade;
  }
  
  fragColor=vec4(col,1.);
}