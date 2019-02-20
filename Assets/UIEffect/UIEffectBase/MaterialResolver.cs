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
    /// 解决材质球问题 比如在改脚本之后材质球丢失用
    /// 同时也能自动生成材质球
    /// </summary>
    public class MaterialResolver
    {
        private static readonly StringBuilder stringBuilder = new StringBuilder();
        
        private static readonly Dictionary<string, Material> materialMap = new Dictionary<string, Material>();

        /// <summary>
        /// 得到或生成材质球
        /// </summary>
        /// <param name="shader">shader</param>
        /// <param name="append">keywords</param>
        /// <returns></returns>
        public static Material GetOrGenerateMaterialVariant(Shader shader, params object[] append)
        {
            if (!shader)
            {
                return null;
            }

            string[] keywords = append.Where(x => (int)x>0)
                .Select(x => x.ToString().ToUpper())
                .ToArray();
            Material mat = GetMaterial(shader, append);

            //如果材质球已经存在了
            if (mat)
            {
                //如果keyword 不匹配( 先排序再用SequenceEqual逐一匹配)
                //则进行储存
                if (!mat.shaderKeywords.OrderBy(x => x).SequenceEqual(keywords.OrderBy(x => x)))
                {
                    mat.shaderKeywords = keywords;//重新设置keyword
                    EditorUtility.SetDirty(mat);
                    if (!Application.isPlaying)
                    {
                        EditorApplication.delayCall += AssetDatabase.SaveAssets;
                    }
                }
                return mat;
            }

            //如果材质球不存在,但是材质Map存在
            string variantName = GetVariantName(shader, append);
            if (materialMap.TryGetValue(variantName, out mat) && mat)
            {
                return mat;
            }

            //否则生成材质球
            Debug.Log("Generate material : " + variantName);
            mat = new Material(shader);
            mat.shaderKeywords = keywords;

            mat.name = variantName;
            mat.hideFlags |= HideFlags.NotEditable;//这里让材质球不能编辑
            materialMap[variantName] = mat;//材质Map储存生成的材质球,因为AssetData 不一定能及时刷新,所以直接储存在map里面

            bool isMainAsset = append.Cast<int>().All(x => x == 0);//如果没有关键字,则是最初始默认的材质球
            EditorApplication.delayCall += () => SaveMaterial(mat, shader, isMainAsset);//储存材质球
            return mat;
        }

        /// <summary>
        /// 储存材质球
        /// </summary>
        /// <param name="mat"></param>
        /// <param name="shader"></param>
        /// <param name="isMainAsset">是否是初始默认资源</param>
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
                mat.hideFlags |= HideFlags.HideInHierarchy;
                AssetDatabase.AddObjectToAsset(mat, materialPath);//覆盖到已经存在的材质球上
            }
            AssetDatabase.SaveAssets();
        }

        /// <summary>
        /// 得到通过shader和Keyword得到材质球的名字
        /// </summary>
        /// <param name="shader"></param>
        /// <param name="append"></param>
        /// <returns></returns>
        public static Material GetMaterial(Shader shader, params object[] append)
        {
            string variantName = GetVariantName(shader, append);
            return AssetDatabase.FindAssets("t:Material " + Path.GetFileName(shader.name))
            .Select(AssetDatabase.GUIDToAssetPath)
            .SelectMany(AssetDatabase.LoadAllAssetsAtPath)
            .OfType<Material>()
            .FirstOrDefault(x => x.name == variantName);
        }

        /// <summary>
        /// 得到默认的材质球路径,如果没有则直接在assets下
        /// </summary>
        /// <param name="shader"></param>
        /// <returns></returns>
        public static string GetDefaultMaterialPath(Shader shader)
        {
            var name = Path.GetFileName(shader.name);
            return AssetDatabase.FindAssets("t:Material " + name)
            .Select(AssetDatabase.GUIDToAssetPath)
            .FirstOrDefault(x => Path.GetFileNameWithoutExtension(x) == name)
            ?? ("Assets/" + name + ".mat");
        }

        /// <summary>
        /// 得到材质球的名字,即材质球-Key0-Key1-Key2
        /// </summary>
        /// <param name="shader"></param>
        /// <param name="append"></param>
        /// <returns></returns>
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
