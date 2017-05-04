using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using UnityEngine.Networking;

class OscHandler : MonoBehaviour
{
    void Start()
    {
        var oscIn = GetComponent<OscIn>();
        oscIn.Map("/bcr2000", (OscMessage msg) =>
        {
            Debug.Log("received message " + msg.address + " " + msg.args.First());
            
        });
    }

    void Update()
    {
        
    }
}