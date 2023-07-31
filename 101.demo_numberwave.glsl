#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;
uniform sampler2D number;

void main(){
  float M,
  A,
  T=u_time;
  vec4 color=vec4(0.);
  for(float R=0.;R<33.;R++){
    vec4 X=vec4(u_resolution,1.,1.);
    
    vec4 p=A*normalize(vec4((gl_FragCoord.xy+gl_FragCoord.xy-X.xy)*
    mat2(cos(A*sin(T*.1)*.3+vec4(0,33,11,0))),X.y,0));
    p.z+=T;
    p.y=abs(abs(p.y)-1.);
    
    X=fract(dot(X=ceil(p*4.),sin(X))+X);
    X.g*=5.;
    M=4.*pow(smoothstep(1.,.47,texture2D(number,(p.xz+ceil(T+X.x))/4.).a),9.)-5.;
    
    A+=p.y*.6-(M+A+A+3.)/67.;
    
    color+=(X.a+.5)*(X+A)*(1.4-p.y)/2e2/M/M/exp(A*.1);
  }
  gl_FragColor=color;
}