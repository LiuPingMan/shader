#ifdef GL_ES
precision mediump float;
#endif

uniform float u_time;
uniform sampler2D number;

varying vec2 v_texcoord;

void main(){
  vec2 uv=v_texcoord;
  vec2 direction=vec2(.01*sin(u_time),.01*cos(u_time));
  vec4 channelR=texture2D(number,uv+direction);
  channelR.g=0.;
  channelR.b=0.;
  vec4 channelG=texture2D(number,uv);
  channelG.r=0.;
  channelG.b=0.;
  vec4 channelB=texture2D(number,uv-direction);
  channelB.r=0.;
  channelB.g=0.;
  vec4 color=channelR+channelG+channelB;
  gl_FragColor=color;
}