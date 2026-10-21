import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sei_validacao_frontend/widgets/admin/user_filters.dart';

void main() {
  testWidgets(
      'filtro acompanha órgão externo, inclusive órgão 0 e retorno a todos',
      (tester) async {
    final pesquisa = TextEditingController();
    int? escolhido;
    Future<void> exibir(int? orgao) => tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: UserFilters(
            pesquisa: pesquisa,
            orgaos: const [
              {'id_orgao': 0, 'sigla': 'ORG0'},
              {'id_orgao': 9, 'sigla': 'ORG9'}
            ],
            idOrgao: orgao,
            situacao: 'TODOS',
            quantidades: const {},
            carregando: false,
            pesquisar: () {},
            alterarOrgao: (valor) => escolhido = valor,
            alterarSituacao: (_) {},
          ).filtroOrgao()),
        ));
    for (final orgao in <int?>[null, 0, 9, null]) {
      await exibir(orgao);
      expect(
          tester
              .state<FormFieldState<int>>(
                  find.byType(DropdownButtonFormField<int>))
              .value,
          orgao);
    }
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ORG0').last);
    await tester.pumpAndSettle();
    expect(escolhido, 0);
    await tester.pumpWidget(const SizedBox.shrink());
    pesquisa.dispose();
  });
}
