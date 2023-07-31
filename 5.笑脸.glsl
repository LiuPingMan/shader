// 将t在a->b区间映射到0->1区间
float remap01(float a,float b,float t){
  return clamp((t-a)/(b-a),0.,1.);
}
// 将t在a->b区间映射到c->d区间
float remap(float a,float b,float c,float d,float t){
  return clamp((t-a)/(b-a),0.,1.)*(d-c)+c;
}
// 在uv坐标系中建立一个以rect.xy为原点的新坐标系
vec2 within(vec2 uv,vec4 rect){
  return(uv-rect.xy)/(rect.zw-rect.xy);
}

vec4 brow(vec2 uv){
  float y=uv.y;
  uv-=.5;
  // 造形
  uv.y+=uv.x*.8+.1;
  uv.x-=.1;
  
  vec4 col=vec4(0.);
  // 眉毛
  float blur=.1;
  float d1=length(uv);
  float s1=smoothstep(.45,.45-blur,d1);
  float d2=length(uv-vec2(.1,-.2)*.7);
  float s2=smoothstep(.5,.5-blur,d2);
  float brow_mask=clamp(s1-s2,0.,1.);
  float col_mask=remap01(.7,.8,y)*.75;
  col_mask*=smoothstep(.6,.9,brow_mask);
  vec4 brow_col=mix(vec4(.4,.2,.2,1.),vec4(1.),col_mask);
  
  // 阴影
  uv.y+=.15;
  blur+=.1;
  d1=length(uv);
  s1=smoothstep(.45,.45-blur,d1);
  d2=length(uv-vec2(.1,-.2)*.7);
  s2=smoothstep(.5,.5-blur,d2);
  float shadow_mask=clamp(s1-s2,0.,1.);
  
  col=mix(col,vec4(0.,0.,0.,1.),smoothstep(0.,1.,shadow_mask)*.5);
  col=mix(col,brow_col,smoothstep(.2,.4,brow_mask));
  return col;
}

vec4 mouth(vec2 uv){
  uv-=.5;
  uv.y*=1.5;
  uv.y-=uv.x*uv.x*2.;
  float d=length(uv);
  // 嘴巴
  vec4 col=vec4(.5,.18,.05,1.);
  col.a=smoothstep(.5,.49,d);
  // 牙齿
  float td=length(uv-vec2(0.,.6));
  vec3 tooth_col=vec3(1.)*smoothstep(.6,.4,d);
  col.rgb=mix(col.rgb,tooth_col,smoothstep(.4,.37,td));
  // 舌头
  td=length(uv+vec2(0,.5));
  col.rgb=mix(col.rgb,vec3(1.,.5,.5),smoothstep(.5,.2,td));
  return col;
}
vec4 eye(vec2 uv,float side){
  uv-=.5;
  uv.x*=side;
  float d=length(uv);
  // 虹膜
  vec4 iris_color=vec4(.3,.5,1.,1.);
  vec4 col=mix(vec4(1.),iris_color,smoothstep(.1,.7,d)*.5);
  col.a=smoothstep(.5,.49,d);
  // 内阴影
  col.rgb*=1.-smoothstep(.45,.5,d)*.5*clamp(-uv.y-uv.x*side,0.,1.);
  // 瞳孔轮廓
  col.rgb=mix(col.rgb,vec3(0.),smoothstep(.3,.28,d));
  // 瞳孔
  iris_color.rgb*=1.+smoothstep(.3,.05,d);
  col.rgb=mix(col.rgb,iris_color.rgb,smoothstep(.28,.25,d));
  col.rgb=mix(col.rgb,vec3(0.),smoothstep(.16,.14,d));
  
  // 高光
  float hignlight=smoothstep(.1,.09,length(uv-vec2(-.15,.15)));
  hignlight+=smoothstep(.07,.05,length(uv-vec2(.08,-.08)));
  col.rgb=mix(col.rgb,vec3(1.),hignlight);
  return col;
}
vec4 head(vec2 uv){
  vec4 col=vec4(.9,.65,.1,1.);
  float d=length(uv);
  
  col.a=smoothstep(.5,.49,d);
  // 阴影
  float edge=remap01(.35,.5,d);
  edge*=edge;
  col.rgb*=1.-edge*.3;
  // 边框
  col.rgb=mix(col.rgb,vec3(.6,.3,.1),smoothstep(.47,.48,d));
  // 高光
  float highlight=smoothstep(.41,.405,d);
  highlight*=remap(-.1,.41,0.,.75,uv.y);
  highlight*=smoothstep(.18,.19,length(uv-vec2(.21,.08)));
  col.rgb=mix(col.rgb,vec3(1.),highlight);
  // 脸颊
  d=length(uv-vec2(.25,-.2));
  float cheek=smoothstep(.2,.01,d)*.4;
  cheek*=smoothstep(.17,.16,d);
  col.rgb=mix(col.rgb,vec3(1,.1,.1),cheek);
  return col;
}

vec4 smiling_face(vec2 uv){
  vec4 col=vec4(0.);
  float side=sign(uv.x);
  uv.x=abs(uv.x);
  vec4 head=head(uv);
  vec4 mouth=mouth(within(uv,vec4(-.3,-.4,.3,-.1)));
  vec4 eye=eye(within(uv,vec4(.03,-.1,.37,.25)),side);
  vec4 brow=brow(within(uv,vec4(.03,.2,.4,.45)));
  col=mix(col,head,head.a);
  col=mix(col,eye,eye.a);
  col=mix(col,mouth,mouth.a);
  col=mix(col,brow,brow.a);
  return col;
}

void mainImage(out vec4 fragColor,in vec2 fragCoord){
  vec2 uv=fragCoord.xy/iResolution.xy;
  uv-=.5;
  uv.x*=iResolution.x/iResolution.y;
  fragColor=smiling_face(uv);
}