package GUIapplicationFilm;

import javax.swing.SwingUtilities;

/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 *
 * @author John
 */
public class accueilPanel extends javax.swing.JPanel {

    /**
     * Creates new form testPanel
     */
    public accueilPanel() {
        initComponents();
    }

    /**
     * This method is called from within the constructor to initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is always
     * regenerated by the Form Editor.
     */
    @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        bienvenueLabel = new javax.swing.JLabel();
        rechercherButton = new javax.swing.JButton();

        setPreferredSize(new java.awt.Dimension(780, 500));

        bienvenueLabel.setFont(new java.awt.Font("Tahoma", 0, 36)); // NOI18N
        bienvenueLabel.setText("The movie database");

        rechercherButton.setText("Rechercher un film");
        rechercherButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                rechercherButtonActionPerformed(evt);
            }
        });

        javax.swing.GroupLayout layout = new javax.swing.GroupLayout(this);
        this.setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, layout.createSequentialGroup()
                .addContainerGap(256, Short.MAX_VALUE)
                .addComponent(bienvenueLabel)
                .addGap(203, 203, 203))
            .addGroup(layout.createSequentialGroup()
                .addGap(31, 31, 31)
                .addComponent(rechercherButton, javax.swing.GroupLayout.PREFERRED_SIZE, 137, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addGap(28, 28, 28)
                .addComponent(bienvenueLabel)
                .addGap(30, 30, 30)
                .addComponent(rechercherButton, javax.swing.GroupLayout.PREFERRED_SIZE, 60, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addContainerGap(338, Short.MAX_VALUE))
        );
    }// </editor-fold>//GEN-END:initComponents

    private void rechercherButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_rechercherButtonActionPerformed
        GUI container = (GUI)SwingUtilities.getWindowAncestor(this); // on prend son grand pere
        container.changeLayout("formulaireRecherche");
    }//GEN-LAST:event_rechercherButtonActionPerformed


    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JLabel bienvenueLabel;
    private javax.swing.JButton rechercherButton;
    // End of variables declaration//GEN-END:variables
}
