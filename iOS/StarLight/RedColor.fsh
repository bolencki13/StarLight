varying highp vec2 textureCoordinate;
uniform sampler2D inputImageTexture;


void main() {
    lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
    
    if (textureColor.rgb[0] > 0.95 && (textureColor.rgb[1] > 0.9 && textureColor.rgb[1] <= 1.0) && (textureColor.rgb[2] > 0.9 && textureColor.rgb[2] <= 1.0)) {
        gl_FragColor = vec4((textureColor.rgb), textureColor.w);
    } else {
        discard;
    }
}
