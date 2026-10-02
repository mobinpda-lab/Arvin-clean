import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/widgets/taxonomy_icon_row.dart';
void main(){testWidgets('taxonomy icon row renders project category and tag',(tester)async{await tester.pumpWidget(const MaterialApp(home:Scaffold(body:TaxonomyIconRow(project:'پروژه',category:'دسته',tags:['برچسب']))));expect(find.byKey(const ValueKey('taxonomy-icon-row')),findsOneWidget);expect(find.byKey(const ValueKey('taxonomy-icon-row-project')),findsOneWidget);expect(find.byKey(const ValueKey('taxonomy-icon-row-category')),findsOneWidget);expect(find.byKey(const ValueKey('taxonomy-icon-row-tag-برچسب')),findsOneWidget);});}
