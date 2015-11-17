/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package classApplicationFilm;

import java.sql.Blob;
import javax.imageio.ImageIO;
import javax.swing.ImageIcon;

/**
 *
 * @author Jerome
 */
public class Film {
    private int id;
    private String titre;
    private String titre_originale;
    private String status;
    private float note_moyenne;
    private int nbrNote;
    private String dateSortie;
    private int runtime;
    private ImageIcon affiche;
    private String overview;
    
    public Film(String t, int i)
    {
        id = i;
        titre = t;
    }
    
    public String getTitre()
    {
        return titre;
    }
    
    public int getId()
    {
        return id;
    }
    
    public void setDateSortie(String d)
    {
        dateSortie = d;
    }
    
    public String getDateSorti()
    {
        return dateSortie;
    }
    
    public void setTitreOriginale(String t)
    {
        titre_originale = t;
    }
    
    public String getTitrOriginale()
    {
        return titre_originale;
    }
    
    public void setStatus(String s)
    {
        status = s;
    }
    
    public String getStatut()
    {
        return status;
    }
    
    public void setNoteMoyenne(float f)
    {
        note_moyenne = f;
    }
    
    public float getNoteMoyenne()
    {
        return note_moyenne;
    }
    
    public void setNbrNote(int n)
    {
        nbrNote = n;
    }
    
    public int getNbrNote()
    {
        return nbrNote;
    }
    
    public void setRuntime(int i)
    {
        runtime = i;
    }
    
    public int getRuntime()
    {
        return runtime;
    }
    
    public void setAffiche(ImageIcon i)
    {
        affiche = i;
    }
    
    public ImageIcon getAffiche()
    {
        return affiche;
    }
    
    public void setOverview(String o)
    {
        overview = o;
    }
    
    public String getOverview()
    {
        return overview;
    }
    
    @Override
    public String toString()
    {
        return id + "    " + titre + "    "+ dateSortie;
    }
}
