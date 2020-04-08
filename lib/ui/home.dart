import 'package:flutter/material.dart';
import 'package:penjualan_voucher/ui/inputpenjualan.dart';
import 'package:penjualan_voucher/models/penjualan.dart';
import 'package:penjualan_voucher/helpers/dbhelper.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

class Home extends StatefulWidget{
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home>{
  DbHelper dbHelper = DbHelper();
  int count = 0;
  List<Penjualan> penjualanList;

  @override
  Widget build(BuildContext context){
    if(penjualanList == null){
      penjualanList = List<Penjualan>();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Penjualan Voucer'),
        leading: Icon(Icons.wifi),
      ),
      body: createListView(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        tooltip: 'Input Penjualan',
        onPressed: () async{
          var penjualan = await navigateToEntryForm(context,null);
          if(penjualan != null) addPenjualan(penjualan);
        },
      ),
    );
  }

  Future<Penjualan> navigateToEntryForm(BuildContext context, Penjualan penjualan) async{
    var result  = await Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (BuildContext context){
          return InputPenjualan(penjualan);
        }
      )
    );
    return result;
  }

  //widget createListView
  ListView createListView(){
    TextStyle textStyle = Theme.of(context).textTheme.subhead;
    //updateListView();
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext, int index){
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            title: Text(this.penjualanList[index].name, style: textStyle,),
            subtitle: Row(
              children: <Widget>[
                Text(this.penjualanList[index].tanggal),
                Text(" | Rp. "+this.penjualanList[index].jumlah,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            //icon delete
            trailing: GestureDetector(
              child: Icon(Icons.delete),
              onTap: (){
                deletePenjualan(penjualanList[index]);
              },
            ),
            //klik list untuk tampilkan form update
            onTap: () async{
              var penjualan = await navigateToEntryForm(
                context,
                this.penjualanList[index]
              );
              if (Penjualan != null) editPenjualan(penjualan);
            },
          ),
        );
      },
    );
  }

  //fungsi tambah penjualan
  void addPenjualan(Penjualan object) async{
    int result = await dbHelper.insert(object);
    if(result>0){
      updateListView();
    }
  }

  //fungsi update penjualan
  void editPenjualan(Penjualan object) async {
    int result = await dbHelper.update(object);
    if(result>0){
      updateListView();
      print("ini edit penjualan result $result");
    }
  }

  //fungsi delete penjualan
  void deletePenjualan(Penjualan object) async{
    int result = await dbHelper.delete(object.id);
    if(result>0){
      updateListView();
    }
  }

  //fungsi menampilkan data terbaru
  void updateListView(){
    final Future<Database> dbFuture = dbHelper.initDb();
    dbFuture.then((datatabase){
      Future<List<Penjualan>> penjualanListFuture=dbHelper.getPenjualanList();
      penjualanListFuture.then((penjualanList){
        setState((){
          this.penjualanList=penjualanList;
          this.count=penjualanList.length;
        });
      });
    });
  }
}