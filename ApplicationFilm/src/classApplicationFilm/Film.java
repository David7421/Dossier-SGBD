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
    
    public Film(String t, int i)
    {
        id = i;
        titre = t;
    }
    
    @Override
    public String toString()
    {
        return id + "-----" + titre;
    }
}
