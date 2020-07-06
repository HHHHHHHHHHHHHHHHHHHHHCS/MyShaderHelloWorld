using UnityEngine;
using UnityEngine.Rendering;

namespace Lighting2D
{
    public struct Light2DProfile
    {
        public Camera camera;
        public CommandBuffer commandBuffer;
        public RenderTexture lightMap;
    }
}