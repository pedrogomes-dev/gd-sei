import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/app_shell.dart';
import '../widgets/display_fields.dart';
import '../widgets/propriedades_assunto.dart';
import '../widgets/propriedades_processo.dart';

class CatalogoScreen extends StatefulWidget {
  final String kind;
  const CatalogoScreen({super.key,required this.kind});
  @override State<CatalogoScreen> createState()=>_CatalogoScreenState();
}
class _CatalogoScreenState extends State<CatalogoScreen> {
  final query=TextEditingController();
  int? version;
  @override void initState(){super.initState();search();}
  String searched='',state='TODOS';
  int total=0;
  Map<String, int> quantidades = {};
  int offset=0,generation=0;
  bool busy=false,more=false;
  List<dynamic> items=[];
  String? error;
  bool get subjects=>widget.kind=='assuntos';
  @override void dispose(){query.dispose();super.dispose();}
  Future<void> search({bool next=false,bool previous=false}) async {
    final request=++generation;
    final text=next||previous?searched:query.text.trim();final page=previous?offset-50:next?offset+50:0;
    setState((){busy=true;error=null;});
    try {
      final result=await ApiService().catalog(widget.kind,text,page,version:next||previous?version:null,state:state);
      if (mounted && request == generation) setState(() {
        items = result['itens'] as List<dynamic>;
        quantidades = Map<String, dynamic>.from(result['quantidades'] as Map? ?? {})
            .map((key, value) => MapEntry(key, int.parse(value.toString())));
        total = int.parse(result['total'].toString());
        more = result['mais'] == true;
        offset = page;
        searched = text;
        version = int.parse(result['versao'].toString());
      });
    }catch(e){if(mounted&&request==generation)setState((){error=e.toString();});}
    finally{if(mounted&&request==generation)setState((){busy=false;});}
  }
  void properties(Map<String, dynamic> row) {
    showDialog<void>(
      context: context,
      builder: (context) => SelectionArea(
        child: AlertDialog(
          title: Row(children: [
            Expanded(child: Text(subjects ? 'Propriedades do Assunto' : 'Propriedades do Tipo de Processo')),
            IconButton(tooltip: 'Fechar', icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
          ]),
          content: SizedBox(
            width: 760,
            child: SingleChildScrollView(
              child: subjects
                  ? PropriedadesAssunto(assunto: row)
                  : PropriedadesProcesso(processo: row),
            ),
          ),
        ),
      ),
    );
  }
  Widget resultTable() {
    Widget cell(Widget child)=>Padding(padding:const EdgeInsets.symmetric(horizontal:12,vertical:16),child:child);
    final descriptionColumn=subjects?2:1;
    return Table(
      columnWidths:{
        0:const FixedColumnWidth(48),
        if(subjects)1:const FixedColumnWidth(100),
        descriptionColumn:const FlexColumnWidth(),
        descriptionColumn+1:const FixedColumnWidth(120),
      },
      defaultVerticalAlignment:TableCellVerticalAlignment.middle,
      border:const TableBorder(horizontalInside:BorderSide(color:Color(0xffe2e8f0))),
      children:[
        TableRow(decoration:const BoxDecoration(color:Color(0xfff5f7fa)),children:[
          const SizedBox.shrink(),if(subjects)cell(const Text('Código')),
          cell(const Text('Descrição')),cell(const Text('Estado')),
        ]),
        ...items.map((row)=>TableRow(children:[
          IconButton(tooltip:'Propriedades',icon:const Icon(Icons.info_outline),onPressed:()=>properties(Map<String,dynamic>.from(row as Map))),
          if(subjects)cell(Text((row['codigo_estruturado']??'—').toString())),
          cell(subjects ? Padding(
            padding: EdgeInsets.only(left: (int.tryParse(
              (row['nivel_hierarquia'] ?? 0).toString(),
            ) ?? 0).clamp(0, 12) * 20.0),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if ((int.tryParse((row['nivel_hierarquia'] ?? 0).toString()) ?? 0) > 0)
                const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: Icon(Icons.subdirectory_arrow_right, size: 18, color: Colors.blueGrey),
                ),
              Expanded(child: Text((row['descricao'] ?? '—').toString())),
            ]),
          ) : Text((row['nome'] ?? '—').toString())),
          cell(Align(alignment:Alignment.centerLeft,child:row['sin_ativo']=='S'?const StatusTag('ATIVO'):row['sin_ativo']=='N'?const StatusTag('INATIVO'):const StatusTag('PENDENTE',label:'Não informado'))),
        ])),
      ]);
  }
  void filtrarEstado(String opcao) {
    setState(() => state = state == opcao ? 'TODOS' : opcao);
    search();
  }

  Widget cardEstado(String opcao, String titulo, IconData icone, Color cor) {
    final selecionado = state == opcao;
    final chave = opcao == 'S' ? 'ativos' : opcao == 'N' ? 'inativos' : 'todos';
    final quantidade = quantidades[chave]?.toString() ?? '—';
    return Semantics(
      button: true,
      selected: selecionado,
      child: Material(
        color: selecionado ? cor.withValues(alpha: 0.08) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: selecionado ? cor : const Color(0xffe2e8f0), width: selecionado ? 2 : 1),
        ),
        child: InkWell(
          onTap: busy ? null : () => filtrarEstado(opcao),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Icon(icone, color: cor),
              const SizedBox(width: 12),
              Expanded(child: Text(titulo, style: TextStyle(color: cor, fontWeight: FontWeight.w600))),
              Text(quantidade, style: TextStyle(color: cor, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              if (selecionado) Icon(Icons.check_circle, color: cor, size: 18),
            ]),
          ),
        ),
      ),
    );
  }

  Widget filtrosEstado() {
    return LayoutBuilder(builder: (context, tamanho) {
      final colunas = tamanho.maxWidth >= 600 ? 3 : 1;
      final largura = (tamanho.maxWidth - (colunas - 1) * 12) / colunas;
      return Wrap(spacing: 12, runSpacing: 12, children: [
        SizedBox(width: largura, child: cardEstado('TODOS', 'Todos', Icons.list_alt, Colors.blue.shade800)),
        SizedBox(width: largura, child: cardEstado('S', 'Ativos', Icons.check_circle_outline, Colors.green.shade800)),
        SizedBox(width: largura, child: cardEstado('N', 'Inativos', Icons.block, Colors.red.shade800)),
      ]);
    });
  }

  Widget barraPesquisa() {
    final campo = TextField(
      controller: query,
      maxLength: 250,
      decoration: InputDecoration(
        labelText: subjects ? 'Buscar por ID, código ou descrição' : 'Buscar por ID, nome ou descrição',
        prefixIcon: const Icon(Icons.search),
      ),
      onSubmitted: (_) { if (!busy) search(); },
    );
    final botao = FilledButton.icon(
      onPressed: busy ? null : () => search(),
      icon: const Icon(Icons.search),
      label: const Text('Pesquisar'),
    );
    return LayoutBuilder(builder: (context, tamanho) {
      if (tamanho.maxWidth < 500) {
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          campo,
          const SizedBox(height: 12),
          Align(alignment: Alignment.centerRight, child: botao),
        ]);
      }
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: campo),
        const SizedBox(width: 16),
        Padding(padding: const EdgeInsets.only(top: 8), child: botao),
      ]);
    });
  }

  @override Widget build(BuildContext context)=>AppShell(title:subjects?'Catálogo de Assuntos':'Catálogo de Tipos de Processo',
    section:subjects?'assuntos':'catalogo-tipos',trail:[subjects?'Assuntos':'Tipos de Processo'],
    child:ListView(padding:const EdgeInsets.fromLTRB(32,0,32,32),children:[
        const Text('Catálogo único da base publicada, incluindo registros ativos e inativos.',style:TextStyle(color:Colors.blueGrey)),
        const SizedBox(height:12),Text(version==null?'':'Versão da base: $version',style:const TextStyle(color:Colors.blueGrey)),
        const SizedBox(height:24),SectionCard(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          barraPesquisa(),
          const SizedBox(height: 16),
          filtrosEstado(),
        ])),
        if(error!=null)Padding(padding:const EdgeInsets.only(bottom:20),child:Text(error!)),
        if(busy)const LinearProgressIndicator(),
        if(version!=null&&!busy)SectionCard(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text('$total registros encontrados',style:const TextStyle(fontWeight:FontWeight.w600)),
          const SizedBox(height:16),
          if(items.isEmpty)const Text('Nenhum registro encontrado.')
          else LayoutBuilder(builder:(context,constraints){
            final minWidth=subjects?720.0:620.0;
            final width=constraints.maxWidth<minWidth?minWidth:constraints.maxWidth;
            return SingleChildScrollView(scrollDirection:Axis.horizontal,child:SizedBox(width:width,child:resultTable()));
          }),
          const SizedBox(height:16),Row(children:[Text('Página ${offset~/50+1} · Exibindo ${items.isEmpty?0:offset+1}–${offset+items.length} de $total'),const Spacer(),
            if(offset>0)TextButton(onPressed:()=>search(previous:true),child:const Text('Anterior')),
            if(more)TextButton(onPressed:()=>search(next:true),child:const Text('Próxima'))]),
        ])),
      ]));
}



