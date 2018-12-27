using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

namespace UIEffect
{
    public class MaterialCache
    {
        /// <summary>
        /// 材质球缓存列表
        /// </summary>
        public static List<MaterialCache> materialCaches = new List<MaterialCache>();

        /// <summary>
        /// 唯一ID
        /// </summary>
        public ulong Hash { get; private set; }

        /// <summary>
        /// 引用数量
        /// </summary>
        public int ReferenceCount { get; private set; }

        /// <summary>
        /// 噪音图片等
        /// </summary>
        public Texture MainTexture { get; private set; }

        /// <summary>
        /// 材质球
        /// </summary>
        public Material MainMaterial { get; private set; }

#if UNITY_EDITOR
        /// <summary>
        /// 每次Play清空缓存
        /// </summary>
        [UnityEditor.InitializeOnLoadMethod]
        private static void ClearCache()
        {
            foreach (var cache in materialCaches)
            {
                cache.MainMaterial = null;
            }

            materialCaches.Clear();
        }
#endif

        /// <summary>
        /// 注册缓存材质球(有图片)
        /// </summary>
        public static MaterialCache Register(ulong hash, Texture texture, Func<Material> onCreateMaterial)
        {
            var cache = materialCaches.FirstOrDefault(x => x.Hash == hash);
            if (cache != null)
            {
                if (cache.MainMaterial)
                {
                    cache.ReferenceCount++;
                }
                else
                {
                    materialCaches.Remove(cache);
                    cache = null;
                }
            }
            else
            {
                cache = new MaterialCache()
                {
                    Hash=hash,
                    MainMaterial=onCreateMaterial(),
                    MainTexture=texture,
                    ReferenceCount=1,
                };
                materialCaches.Add(cache);
            }

            return cache;
        }

        /// <summary>
        /// 注册缓存材质球(没有图片)
        /// </summary>
        public static MaterialCache Register(ulong hash, Func<Material> onCreateMaterial)
        {
            var cache = materialCaches.FirstOrDefault(x => x.Hash == hash);
            if (cache != null)
            {
                cache.ReferenceCount++;
            }

            if (cache == null)
            {
                cache = new MaterialCache()
                {
                    Hash=hash,
                    MainMaterial=onCreateMaterial(),
                    ReferenceCount=1
                };
                materialCaches.Add(cache);
            }

            return cache;
        }

        /// <summary>
        /// 注销材质球
        /// </summary>
        public static void Unregister(MaterialCache cache)
        {
            if (cache == null)
            {
                return;
            }

            cache.ReferenceCount--;
            if (cache.ReferenceCount <= 0)
            {
                materialCaches.Remove(cache);
                cache.MainMaterial = null;
                cache.MainTexture = null;
            }
        }
    }
}

