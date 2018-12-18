using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MathTable : MonoBehaviour
{
    [SerializeField]
    private Transform cubePrefab;

    [SerializeField]
    private float startPos = -10, endPos = -6;

    [SerializeField, Range(10, 1000)]
    private int oneCount = 100;

    private Transform parent;
    private float _startPos, _endPos;
    private int _oneCount,_p0,_p1;

    private void Awake()
    {
        _p0 = -2;
        _p1 = 2;
        parent = transform;
    }

    private void Update()
    {
        Spawn();
    }

    private void Spawn()
    {
        if (!cubePrefab)
        {
            Debug.Log("cubePrefab is null");
        }
        if (endPos <= startPos)
        {
            Debug.Log("start or end error");
        }
        if (startPos != _startPos || endPos != _endPos
            || oneCount != _oneCount)
        {
            _startPos = startPos;
            _endPos = endPos;
            _oneCount = oneCount;

            foreach (Transform ts in parent)
            {
                Destroy(ts.gameObject);
            }

            float scale = 1.0f / oneCount;
            Vector3 vec3Sacle = Vector3.one * scale;

            cubePrefab.localScale = vec3Sacle;

            float nowPOS = startPos;
            for (float x = _p0; x < _p1; x++)
            {
                nowPOS++;
                float f = nowPOS;
                for (f = 0; f <= 1; f += scale)
                {
                    Vector3 pos = new Vector3(x+f, Cal(nowPOS+f), 0);
                    Instantiate(cubePrefab, pos, Quaternion.identity, parent);
                }
    
            }


            startPos += Time.deltaTime;
            endPos += Time.deltaTime;
        }
    }

    private float Cal(float x)
    {

        float y = Mathf.Sin(Mathf.PI * (x ));
        y += Mathf.Sin(2f * Mathf.PI * (x )) / 2f;
        y *= 2f / 3f;
        return y;

        //return Mathf.Sin(x) + Mathf.Cos(x);

        //return Mathf.Pow((x - 1), 4) + 5 * x * x * x - 8 * x * x + 3 * x;
    }
}
