/*
* UniOSC
* Copyright © 2014-2015 Stefan Schlupek
* All rights reserved
* info@monoflow.org
*/
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;
using OSCsharp.Data;
using UniOSC;


public class OSCReceive : UniOSCEventTarget
{
    void Awake()
    {
    }

    public override void OnOSCMessageReceived(UniOSCEventArgs args)
    {

        OscMessage msg = (OscMessage)args.Packet;

//        if (msg.Data.Count < 3) return;
//        if (!(msg.Data[0] is System.Single)) return;

//        Debug.Log(msg.Data[0]);
        Debug.Log(msg.Data.Count);
        var e = msg.Data.GetEnumerator();
        e.MoveNext();

       
        
    }


}