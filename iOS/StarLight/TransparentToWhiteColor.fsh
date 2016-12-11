varying highp vec2 textureCoordinate;
uniform sampler2D inputImageTexture;

void main() {
    lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
    
    if (textureColor.a < 0.5) {
        textureColor.rgb[0] = 0.0;
        textureColor.rgb[1] = 0.0;
        textureColor.rgb[2] = 0.0;
    }
    
    gl_FragColor = vec4((textureColor.rgb), textureColor.w);
}
