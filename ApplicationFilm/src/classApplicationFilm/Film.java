/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package classApplicationFilm;

/**
 *
 * @author Jerome
 */
public class Film {
    private int id;
    private String titre;
    private String dateSortie;
    
    public Film(String t, int i)
    {
        id = i;
        titre = t;
    }
    
    public void setDateSortie(String d)
    {
        dateSortie = d;
    }
    
    @Override
    public String toString()
    {
        return id + "    " + titre + "    "+ dateSortie;
    }
}
