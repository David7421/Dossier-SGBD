/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package GUIapplicationFilm;

import classApplicationFilm.Film;
import java.sql.Blob;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.swing.DefaultListModel;
import javax.swing.ImageIcon;
import javax.swing.SwingUtilities;
import oracle.jdbc.OracleTypes;

/**
 *
 * @author Jerome
 */
public class affichageFilm extends javax.swing.JPanel {
    
    private int pNumber;
    private int filmID;
    /**
     * Creates new form affichageFilm
     */
    public affichageFilm() {
        initComponents();
        DefaultListModel acteur = new DefaultListModel();
        acteurList.setModel(acteur);
        
        DefaultListModel real = new DefaultListModel();
        realList.setModel(real);
    }
    
    public void setFilm(Film f)
    {
        //Affichage champs films
        afficheLabel.setIcon(new javax.swing.ImageIcon(getClass().getResource("/GUIapplicationFilm/Untitled.png")));
        TitreLabel.setText(f.getTitre());
        titreOriginalLabel.setText("Titre originale : "+ f.getTitrOriginale());
        runtimeLabel.setText("Runtime : " + f.getRuntime() + " min");
        nbrVoteTmdbLabel.setText("Nombre votes tmdb : "+f.getNbrNote());
        moyTmdbLabel.setText("Moyenne tmdb : " + f.getNoteMoyenne());
        
        overviewArea.setLineWrap(true);
        overviewArea.setWrapStyleWord(true);
        overviewArea.setText(f.getOverview());
        
        filmID = f.getId();
                
        GUI container = (GUI)SwingUtilities.getWindowAncestor(this); // on prend son grand pere
        CallableStatement cs = null;
        Connection conDB = container.getBeanbd().getConnexion();
        ResultSet rs = null;
        
        /*RECUPERATION AFFICHE FILM*/
        try {
            cs =  conDB.prepareCall("{? = call PACKAGERECHERCHE.getAfficheFilm(?)}");
            cs.registerOutParameter(1, OracleTypes.CURSOR);
            cs.setInt(2, f.getId());
            cs.executeQuery();
            rs = (ResultSet)cs.getObject(1);
            
            if(rs.next())
            {
                Blob b = rs.getBlob(1);
                ImageIcon im = new ImageIcon(b.getBytes(1, (int)b.length()));
                afficheLabel.setIcon(im);
                f.setAffiche(im);
            }
            
        } catch (SQLException ex) {
            System.err.println("err " + ex);
        }
        
        /*RECUPERATION NOTES USER*/
        
        try {
            cs =  conDB.prepareCall("{? = call PACKAGERECHERCHE.getNoteUtilisateurFilm(?)}");
            cs.registerOutParameter(1, OracleTypes.CURSOR);
            cs.setInt(2, f.getId());
            cs.executeQuery();
            rs = (ResultSet)cs.getObject(1);
            
            if(rs.next())
            {
                nbrVoteLabel.setText("Nombre vote : " + rs.getString(1));
                moyenneVoteLabel.setText("Moyenne vote : " + rs.getString(2));
            }
            
        } catch (SQLException ex) {
            System.err.println("err " + ex);
        }
        
        /*RECUPERATION DES ACTEURS*/
        DefaultListModel acteur = (DefaultListModel) acteurList.getModel();
        acteur.clear();
        try {
            cs =  conDB.prepareCall("{? = call PACKAGERECHERCHE.getActeursFilm(?)}");
            cs.registerOutParameter(1, OracleTypes.CURSOR);
            cs.setInt(2, f.getId());
            cs.executeQuery();
            rs = (ResultSet)cs.getObject(1);
            
            while(rs.next())
            {
                acteur.addElement(rs.getString(1));
            }
            
        } catch (SQLException ex) {
            System.err.println("err " + ex);
        }
        
        /*RECUPERATION REALISATEURS*/
        DefaultListModel real = (DefaultListModel) realList.getModel();
        real.clear();
        try {
            cs =  conDB.prepareCall("{? = call PACKAGERECHERCHE.getRealisateursFilm(?)}");
            cs.registerOutParameter(1, OracleTypes.CURSOR);
            cs.setInt(2, f.getId());
            cs.executeQuery();
            rs = (ResultSet)cs.getObject(1);
            
            while(rs.next())
            {
                real.addElement(rs.getString(1));
            }
            
        } catch (SQLException ex) {
            System.err.println("err " + ex);
        }
        
        /*Affichage première page d'avis */
        pNumber = 1;
        pageNumberLabel.setText(Integer.toString(pNumber)); 
        
        avisArea.setLineWrap(true);
        avisArea.setWrapStyleWord(true);
        avisArea.setText("");
        
        try {
            cs =  conDB.prepareCall("{? = call PACKAGERECHERCHE.getAvisFilm(?, ?)}");
            cs.registerOutParameter(1, OracleTypes.CURSOR);
            cs.setInt(2, f.getId());
            cs.setInt(3, pNumber);
            cs.executeQuery();
            rs = (ResultSet)cs.getObject(1);
            
            while(rs.next())
            {
                avisArea.append("User : " + rs.getString(1) + "\n");
                avisArea.append("Avis : " + rs.getString(2) + "\n\n");
                avisArea.append("---------------------------------\n\n");    
            }
            
        } catch (SQLException ex) {
            System.err.println("err " + ex);
        }
    }

    /**
     * This method is called from within the constructor to initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is always
     * regenerated by the Form Editor.
     */
    @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        afficheLabel = new javax.swing.JLabel();
        TitreLabel = new javax.swing.JLabel();
        menuButton = new javax.swing.JButton();
        titreOriginalLabel = new javax.swing.JLabel();
        runtimeLabel = new javax.swing.JLabel();
        moyTmdbLabel = new javax.swing.JLabel();
        nbrVoteTmdbLabel = new javax.swing.JLabel();
        moyenneVoteLabel = new javax.swing.JLabel();
        nbrVoteLabel = new javax.swing.JLabel();
        jScrollPane1 = new javax.swing.JScrollPane();
        acteurList = new javax.swing.JList();
        jScrollPane2 = new javax.swing.JScrollPane();
        realList = new javax.swing.JList();
        acteursLabel = new javax.swing.JLabel();
        realLabel = new javax.swing.JLabel();
        jScrollPane3 = new javax.swing.JScrollPane();
        overviewArea = new javax.swing.JTextArea();
        jLabel1 = new javax.swing.JLabel();
        jScrollPane4 = new javax.swing.JScrollPane();
        avisArea = new javax.swing.JTextArea();
        jLabel2 = new javax.swing.JLabel();
        precedentButton = new javax.swing.JButton();
        suivantButton = new javax.swing.JButton();
        pageNumberLabel = new javax.swing.JLabel();

        afficheLabel.setIcon(new javax.swing.ImageIcon(getClass().getResource("/GUIapplicationFilm/Untitled.png"))); // NOI18N
        afficheLabel.setToolTipText("");

        TitreLabel.setFont(new java.awt.Font("Tahoma", 0, 24)); // NOI18N
        TitreLabel.setText("TITRE FILM");

        menuButton.setText("menu");
        menuButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                menuButtonActionPerformed(evt);
            }
        });

        titreOriginalLabel.setText("Titre originale :");

        runtimeLabel.setText("runtime : ");

        moyTmdbLabel.setText("Moyenne tmdb :");

        nbrVoteTmdbLabel.setText("Nbr vote tmdb :");

        moyenneVoteLabel.setText("Moyenne vote : ");

        nbrVoteLabel.setText("Nombre votes : ");

        jScrollPane1.setViewportView(acteurList);

        jScrollPane2.setViewportView(realList);

        acteursLabel.setText("Acteurs : ");

        realLabel.setText("Réalisateurs :");

        overviewArea.setEditable(false);
        overviewArea.setColumns(20);
        overviewArea.setRows(5);
        jScrollPane3.setViewportView(overviewArea);

        jLabel1.setText("Overview :");

        avisArea.setColumns(20);
        avisArea.setRows(5);
        jScrollPane4.setViewportView(avisArea);

        jLabel2.setText("Avis : ");

        precedentButton.setText("Précédent");
        precedentButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                precedentButtonActionPerformed(evt);
            }
        });

        suivantButton.setText("Suivant");
        suivantButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                suivantButtonActionPerformed(evt);
            }
        });

        pageNumberLabel.setText("1");

        javax.swing.GroupLayout layout = new javax.swing.GroupLayout(this);
        this.setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(layout.createSequentialGroup()
                        .addGap(29, 29, 29)
                        .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(moyTmdbLabel)
                            .addComponent(nbrVoteTmdbLabel)
                            .addComponent(moyenneVoteLabel)
                            .addComponent(nbrVoteLabel)
                            .addGroup(layout.createSequentialGroup()
                                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                    .addComponent(afficheLabel, javax.swing.GroupLayout.PREFERRED_SIZE, 161, javax.swing.GroupLayout.PREFERRED_SIZE)
                                    .addComponent(titreOriginalLabel)
                                    .addComponent(runtimeLabel))
                                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                    .addGroup(layout.createSequentialGroup()
                                        .addGap(128, 128, 128)
                                        .addComponent(TitreLabel))
                                    .addGroup(layout.createSequentialGroup()
                                        .addGap(64, 64, 64)
                                        .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                            .addGroup(layout.createSequentialGroup()
                                                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                                    .addComponent(acteursLabel)
                                                    .addComponent(jScrollPane1, javax.swing.GroupLayout.PREFERRED_SIZE, 165, javax.swing.GroupLayout.PREFERRED_SIZE)
                                                    .addComponent(jLabel1))
                                                .addGap(84, 84, 84)
                                                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                                                    .addComponent(realLabel)
                                                    .addComponent(jScrollPane2, javax.swing.GroupLayout.PREFERRED_SIZE, 185, javax.swing.GroupLayout.PREFERRED_SIZE)))
                                            .addComponent(jScrollPane3, javax.swing.GroupLayout.PREFERRED_SIZE, 434, javax.swing.GroupLayout.PREFERRED_SIZE)))))))
                    .addGroup(layout.createSequentialGroup()
                        .addContainerGap()
                        .addComponent(menuButton)
                        .addGap(257, 257, 257)
                        .addComponent(precedentButton)
                        .addGap(54, 54, 54)
                        .addComponent(pageNumberLabel)))
                .addContainerGap(93, Short.MAX_VALUE))
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, layout.createSequentialGroup()
                .addGap(0, 0, Short.MAX_VALUE)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING)
                    .addComponent(suivantButton)
                    .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                        .addComponent(jLabel2)
                        .addComponent(jScrollPane4, javax.swing.GroupLayout.PREFERRED_SIZE, 279, javax.swing.GroupLayout.PREFERRED_SIZE)))
                .addGap(176, 176, 176))
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addContainerGap()
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING)
                    .addComponent(afficheLabel, javax.swing.GroupLayout.PREFERRED_SIZE, 200, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addGroup(layout.createSequentialGroup()
                        .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.TRAILING)
                            .addGroup(layout.createSequentialGroup()
                                .addComponent(TitreLabel)
                                .addGap(11, 11, 11)
                                .addComponent(acteursLabel)
                                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                                .addComponent(jScrollPane1, javax.swing.GroupLayout.PREFERRED_SIZE, 103, javax.swing.GroupLayout.PREFERRED_SIZE))
                            .addGroup(layout.createSequentialGroup()
                                .addComponent(realLabel)
                                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                                .addComponent(jScrollPane2, javax.swing.GroupLayout.PREFERRED_SIZE, 103, javax.swing.GroupLayout.PREFERRED_SIZE)))
                        .addGap(18, 18, 18)
                        .addComponent(jLabel1)))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(layout.createSequentialGroup()
                        .addComponent(titreOriginalLabel)
                        .addGap(8, 8, 8)
                        .addComponent(runtimeLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(moyTmdbLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(nbrVoteTmdbLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(moyenneVoteLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(nbrVoteLabel)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                        .addComponent(menuButton))
                    .addGroup(layout.createSequentialGroup()
                        .addComponent(jScrollPane3, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(4, 4, 4)
                        .addComponent(jLabel2)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(jScrollPane4, javax.swing.GroupLayout.PREFERRED_SIZE, 108, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                            .addComponent(precedentButton)
                            .addComponent(suivantButton)
                            .addComponent(pageNumberLabel))
                        .addGap(0, 5, Short.MAX_VALUE)))
                .addContainerGap())
        );
    }// </editor-fold>//GEN-END:initComponents

    private void menuButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_menuButtonActionPerformed
        GUI container = (GUI)SwingUtilities.getWindowAncestor(this); // on prend son grand pere
        container.changeLayout("accueil");
    }//GEN-LAST:event_menuButtonActionPerformed

    private void precedentButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_precedentButtonActionPerformed
        if(pNumber == 1)
            return;
        
        pNumber--;
        pageNumberLabel.setText(Integer.toString(pNumber));
        
        GUI container = (GUI)SwingUtilities.getWindowAncestor(this); // on prend son grand pere
        CallableStatement cs = null;
        Connection conDB = container.getBeanbd().getConnexion();
        ResultSet rs = null;
        
        avisArea.setText("");
        
        try {
            cs =  conDB.prepareCall("{? = call PACKAGERECHERCHE.getAvisFilm(?, ?)}");
            cs.registerOutParameter(1, OracleTypes.CURSOR);
            cs.setInt(2, filmID);
            cs.setInt(3, pNumber);
            cs.executeQuery();
            rs = (ResultSet)cs.getObject(1);
            
            while(rs.next())
            {
                avisArea.append("User : " + rs.getString(1) + "\n");
                avisArea.append("Avis : " + rs.getString(2) + "\n\n");
                avisArea.append("---------------------------------\n\n");    
            }
            
        } catch (SQLException ex) {
            System.err.println("err " + ex);
        }
    }//GEN-LAST:event_precedentButtonActionPerformed

    private void suivantButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_suivantButtonActionPerformed

        pNumber++;
        pageNumberLabel.setText(Integer.toString(pNumber));
        
        GUI container = (GUI)SwingUtilities.getWindowAncestor(this); // on prend son grand pere
        CallableStatement cs = null;
        Connection conDB = container.getBeanbd().getConnexion();
        ResultSet rs = null;
        
        avisArea.setText("");
        
        try {
            cs =  conDB.prepareCall("{? = call PACKAGERECHERCHE.getAvisFilm(?, ?)}");
            cs.registerOutParameter(1, OracleTypes.CURSOR);
            cs.setInt(2, filmID);
            cs.setInt(3, pNumber);
            cs.executeQuery();
            rs = (ResultSet)cs.getObject(1);
            
            while(rs.next())
            {
                avisArea.append("User : " + rs.getString(1) + "\n");
                avisArea.append("Avis : " + rs.getString(2) + "\n\n");
                avisArea.append("---------------------------------\n\n");    
            }
            
        } catch (SQLException ex) {
            System.err.println("err " + ex);
        }
    }//GEN-LAST:event_suivantButtonActionPerformed


    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JLabel TitreLabel;
    private javax.swing.JList acteurList;
    private javax.swing.JLabel acteursLabel;
    private javax.swing.JLabel afficheLabel;
    private javax.swing.JTextArea avisArea;
    private javax.swing.JLabel jLabel1;
    private javax.swing.JLabel jLabel2;
    private javax.swing.JScrollPane jScrollPane1;
    private javax.swing.JScrollPane jScrollPane2;
    private javax.swing.JScrollPane jScrollPane3;
    private javax.swing.JScrollPane jScrollPane4;
    private javax.swing.JButton menuButton;
    private javax.swing.JLabel moyTmdbLabel;
    private javax.swing.JLabel moyenneVoteLabel;
    private javax.swing.JLabel nbrVoteLabel;
    private javax.swing.JLabel nbrVoteTmdbLabel;
    private javax.swing.JTextArea overviewArea;
    private javax.swing.JLabel pageNumberLabel;
    private javax.swing.JButton precedentButton;
    private javax.swing.JLabel realLabel;
    private javax.swing.JList realList;
    private javax.swing.JLabel runtimeLabel;
    private javax.swing.JButton suivantButton;
    private javax.swing.JLabel titreOriginalLabel;
    // End of variables declaration//GEN-END:variables
}
