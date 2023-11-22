#version 330 core


out vec4 FragClr;

in vec3 ourColor;
in vec2 TexCoord;
uniform sampler2D ourTexture;

//in vec4 vertexColor;
//uniform vec4 outColor;

void main(void)
{
        FragClr = texture(ourTexture, TexCoord)*vec4(ourColor,1.0);
        //FragClr = vec4(ourColor,1.0);
}