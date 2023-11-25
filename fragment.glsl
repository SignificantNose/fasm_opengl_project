#version 330 core


out vec4 FragClr;

in vec2 TexCoord;
uniform sampler2D ourTexture;


void main(void)
{
        FragClr = texture(ourTexture, TexCoord);
}