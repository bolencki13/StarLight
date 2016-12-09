varying highp vec2 textureCoordinate;
uniform sampler2D inputImageTexture;


void main() {
    lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
    
    if (textureColor.rgb[0] > 0.6 && textureColor.rgb[1] < 0.4  && textureColor.rgb[2] < 0.4) {
        gl_FragColor = vec4((textureColor.rgb), textureColor.w);
    } else {
        discard;
    }
}
