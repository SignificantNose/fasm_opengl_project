#version 330 core


out vec4 FragClr;

in vec2 TexCoord;
uniform sampler2D theTexture;


void main(void)
{
        FragClr = texture(theTexture, TexCoord);
}