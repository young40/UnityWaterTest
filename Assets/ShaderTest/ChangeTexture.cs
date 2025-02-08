using UnityEngine;

public class ChangeTexture : MonoBehaviour
{
    public Texture Texture;
    
    public MeshRenderer MeshRenderer;
    
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        MeshRenderer.material.mainTexture = Texture;
        // MeshRenderer.material.SetTexture("_MainTex", Texture);
        MeshRenderer.material.SetTexture("_Sub1Tex", Texture);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
