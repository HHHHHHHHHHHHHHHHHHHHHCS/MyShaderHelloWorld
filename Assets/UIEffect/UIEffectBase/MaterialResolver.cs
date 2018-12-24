#if UNITY_EDITOR
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEngine;

namespace UIEffect
{
    /// <summary>
    /// 解决材质球 在改脚本之后丢失用
    /// </summary>
    public class MaterialResolver
    {
        private static readonly StringBuilder stringBuilder = new StringBuilder();
        
        private static readonly Dictionary<string, Material> materialMap = new Dictionary<string, Material>();

        public static Material GetOrGenerateMaterialVariant(Shader shader, params object[] append)
        {
            if (!shader)
            {
                return null;
            }

            string[] keywords = append.Where(x => 0 < (int)x)
                .Select(x => x.ToString().ToUpper())
                .ToArray();
            Material mat = GetMaterial(shader, append);
            if (mat)
            {
                if (!mat.shaderKeywords.OrderBy(x => x).SequenceEqual(keywords.OrderBy(x => x)))
                {
                    mat.shaderKeywords = keywords;
                    EditorUtility.SetDirty(mat);
                    if (!Application.isPlaying)
                    {
                        EditorApplication.delayCall += AssetDatabase.SaveAssets;
                    }
                }
                return mat;
            }

            string variantName = GetVariantName(shader, append);
            if (materialMap.TryGetValue(variantName, out mat) && mat)
            {
                return mat;
            }

            Debug.Log("Generate material : " + variantName);
            mat = new Material(shader);
            mat.shaderKeywords = keywords;

            mat.name = variantName;
            mat.hideFlags |= HideFlags.NotEditable;
            materialMap[variantName] = mat;

            bool isMainAsset = append.Cast<int>().All(x => x == 0);
            EditorApplication.delayCall += () => SaveMaterial(mat, shader, isMainAsset);
            return mat;
        }

        static void SaveMaterial(Material mat, Shader shader, bool isMainAsset)
        {
            string materialPath = GetDefaultMaterialPath(shader);


            if (isMainAsset)
            {
                Directory.CreateDirectory(Path.GetDirectoryName(materialPath));
                AssetDatabase.CreateAsset(mat, materialPath);
            }
            else
            {
                GetOrGenerateMaterialVariant(shader);
                mat.hideFlags |= HideFlags.HideInHierarchy;
                AssetDatabase.AddObjectToAsset(mat, materialPath);
            }
            AssetDatabase.SaveAssets();
        }

        public static Material GetMaterial(Shader shader, params object[] append)
        {
            string variantName = GetVariantName(shader, append);
            return AssetDatabase.FindAssets("t:Material " + Path.GetFileName(shader.name))
            .Select(AssetDatabase.GUIDToAssetPath)
            .SelectMany(AssetDatabase.LoadAllAssetsAtPath)
            .OfType<Material>()
            .FirstOrDefault(x => x.name == variantName);
        }

        public static string GetDefaultMaterialPath(Shader shader)
        {
            var name = Path.GetFileName(shader.name);
            return AssetDatabase.FindAssets("t:Material " + name)
            .Select(AssetDatabase.GUIDToAssetPath)
            .FirstOrDefault(x => Path.GetFileNameWithoutExtension(x) == name)
            ?? ("Assets/" + name + ".mat");
        }

        public static string GetVariantName(Shader shader, params object[] append)
        {
            stringBuilder.Length = 0;

            stringBuilder.Append(Path.GetFileName(shader.name));
            foreach (object mode in append.Where(x => 0 < (int)x))
            {
                stringBuilder.Append("-");
                stringBuilder.Append(mode.ToString());
            }
            return stringBuilder.ToString();
        }
    }
}
#endif
