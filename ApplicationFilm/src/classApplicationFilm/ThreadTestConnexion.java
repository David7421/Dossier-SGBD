/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package classApplicationFilm;

import GUIapplicationFilm.GUI;

/**
 *
 * @author Jerome
 */
public class ThreadTestConnexion extends Thread{
    
    private GUI application;
    
    public ThreadTestConnexion(GUI a)
    {
        application = a;
    }
    
    
    @Override
    public void run()
    {
        while(true)
        {
            try {
                //Thread.sleep(120000);//Toutes les 2 minutes
                Thread.sleep(5000);
            } catch (InterruptedException ex) {
                System.err.println("Sleep interrompu");
            }
            
            application.setConnexion();
        }
    }
}
