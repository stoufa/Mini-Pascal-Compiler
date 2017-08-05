#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>

namespace Ui {
class MainWindow;
}

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = 0);
    ~MainWindow();

private slots:
    void on_nouveau_btn_clicked();
    void on_ouvrir_btn_clicked();
    void on_enregistrer_btn_clicked();
    void on_compiler_btn_clicked();
    void on_a_propos_btn_clicked();

private:
    Ui::MainWindow *ui;
};

#endif // MAINWINDOW_H
