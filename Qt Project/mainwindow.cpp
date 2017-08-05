#include "mainwindow.h"
#include "ui_mainwindow.h"
#include <QMessageBox>
#include <QFileDialog>
#include <QFile>
#include <QTextStream>
#include <QDesktopServices>
#include <QUrl>
#include <QProcess>
#include <QTimer>
#include <windows.h>
#include <QMediaPlayer>

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);
}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::on_nouveau_btn_clicked()
{
    ui->code_plainTextEdit->clear();
    ui->analysisOutput_plainTextEdit->clear();
}

void MainWindow::on_ouvrir_btn_clicked()
{
    QString filename = QFileDialog::getOpenFileName(
        this,
        tr("Ouvrir"),   // title of the file dialog
        QString(),      // default folder to open from (empty string -> directory of this application)
        "Fichiers pascal (*.pas);;Tous les fichiers (*.*)"  // type of files
    );
    if(!filename.isNull() && !filename.isEmpty()) {   // if the user didn't pressed Cancel
        // clear code and output texts
        ui->code_plainTextEdit->clear();
        ui->analysisOutput_plainTextEdit->clear();

        QFile file(filename);
        if(!file.open(QIODevice::ReadOnly|QIODevice::Text)) {   // if the file won't open
            QMessageBox::warning(0,"avertissement","erreur pendant l'ouverture du fichier: "+filename); // display the error message
            return; // exit the method
        }
        QTextStream in(&file);
        ui->code_plainTextEdit->setPlainText(in.readAll());    // display the file's content
        file.close();
    }
}

void MainWindow::on_enregistrer_btn_clicked()
{
    QString filename = QFileDialog::getSaveFileName(
        this,
        tr("Enregistrer sous"),    // title of the file dialog
        QString(),              // default folder to open from (empty string -> directory of this application)
        "Fichiers pascal (*.pas);;Tous les fichiers (*.*)"  // type of files
    );
    if(!filename.isEmpty()) {
        // sauvegarder le fichier
        QString str = ui->code_plainTextEdit->document()->toPlainText();  // toPlainText() and not toHTML() !
        //  Is it possible to read data from the text browser of QT GUI
        //  http://stackoverflow.com/questions/11795616/is-it-possible-to-read-data-from-the-text-browser-of-qt-gui
        QFile file(filename);
        if(!file.open(QIODevice::WriteOnly|QIODevice::Text)) {   // if the file won't open
            QMessageBox::warning(0,"avertissement","erreur pendant la création du fichier: "+filename); // display the error message
            return; // exit the method
        }
        QTextStream out(&file);
        out << str << endl;
        file.close();
        QMessageBox::information(
            this,
            tr("Information"),
            filename + ": fichier sauvegardé !"
        );
    }
}

void MainWindow::on_compiler_btn_clicked()
{
    // sauvegarder le code dans un fichier "code.pas"
    QString str = ui->code_plainTextEdit->document()->toPlainText();  // toPlainText() and not toHTML() !
    //qInfo() << "str: " << str;

    //  Is it possible to read data from the text browser of QT GUI
    //  http://stackoverflow.com/questions/11795616/is-it-possible-to-read-data-from-the-text-browser-of-qt-gui
    QString path = QCoreApplication::applicationDirPath()+"/code.pas";  // path of the analyser input file
    //qInfo() << "path: " << path;

    //QString analyserPath = QCoreApplication::applicationDirPath()+"/analyseur.exe"; // path of the analyser executable
    //  Qt/C++: Icons not showing up when program is run
    //  http://stackoverflow.com/questions/4114418/qt-c-icons-not-showing-up-when-program-is-run
    //  C++ Qt 13 - Resource Files
    //  https://www.youtube.com/watch?v=sWIQIi4lg58

    QString analyserPath = QCoreApplication::applicationDirPath()+"/analyseur.exe"; // path of the analyser executable (didn't put it in resources to facilitate changing it later on)
    //qInfo() << "analyserPath: " << analyserPath;

    QFile file(path);
    if(!file.open(QIODevice::WriteOnly|QIODevice::Text)) {   // if the file won't open
        QMessageBox::warning(0,"avertissement","erreur pendant la lecture du fichier: "+path); // display the error message
        return; // exit the method
    }
    QTextStream out(&file);
    out << str << endl;
    file.close();
    // QProcess issue in executing a exe with arguments
    // http://stackoverflow.com/questions/23243436/qprocess-issue-in-executing-a-exe-with-arguments
    QStringList arguments;  // arguments list (to be passed to the analyser)
    arguments << path;  // the code source file as an argument
    //QProcess::startDetached(analyserPath,arguments);    // executing the analyser and passing its arguments

    //  read QProcess output to string
    //  http://stackoverflow.com/questions/17344807/read-qprocess-output-to-string
    QProcess process;
    process.start(analyserPath, arguments);
    process.waitForFinished(); // sets current thread to sleep and waits for pingProcess end
    QString output(process.readAllStandardOutput());
    //QMessageBox::information(0,"information","output: "+output);


    //Sleep(2000);    // wait for 2 seconds (until the analyser terminates its execution)
    //  Sleep for milliseconds
    //  http://stackoverflow.com/questions/4184468/sleep-for-milliseconds

    /*
    // lire le fichier généré par l'analyseur, pour afficher son contenu
    QString filename = QCoreApplication::applicationDirPath()+"/output.txt";    // path of the analyser output file
    QFile outfile(filename);
    if(!outfile.open(QIODevice::ReadOnly|QIODevice::Text)) {    // if the file won't open
        QMessageBox::warning(0,"avertissement","erreur lors de la création du fichier: "+filename);  // display the error message
        return; // exit the method
    }
    QTextStream in(&outfile);
    */

    ui->analysisOutput_plainTextEdit->setPlainText(output);
    //outfile.close();

    //  réussite de la compilation (jouer un son)
    //  http://doc.qt.io/qt-5/audiooverview.html
    //  http://doc.qt.io/qt-5/qmediaplayer.html
    QMediaPlayer *player = new QMediaPlayer;
    player->setMedia(QUrl::fromLocalFile(QCoreApplication::applicationDirPath()+"/sons/tada.wav")); // read from resources
    //player->setVolume(50);
    player->play();
}

void MainWindow::on_a_propos_btn_clicked()
{
    QMessageBox::information(this, "A propos", "Créée par: Mustapha Sahli");
}
