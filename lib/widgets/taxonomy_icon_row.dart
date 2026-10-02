import 'package:flutter/material.dart';
import '../arvin_colors.dart';
class TaxonomyIconRow extends StatelessWidget {
  const TaxonomyIconRow({super.key, this.project, this.category, this.tags = const <String>[], this.maxTags = 2});
  final String? project, category; final List<String> tags; final int maxTags;
  @override Widget build(BuildContext context) {
    final p=project?.trim(), c=category?.trim();
    final ts=tags.map((v)=>v.trim()).where((v)=>v.isNotEmpty).take(maxTags).toList(growable:false);
    final children=<Widget>[
      if(p?.isNotEmpty==true) _chip(Icons.folder_outlined,p!,ArvinColors.project,ArvinColors.projectSoft,const ValueKey('taxonomy-icon-row-project')),
      if(c?.isNotEmpty==true) _chip(Icons.grid_view_rounded,c!,ArvinColors.category,ArvinColors.categorySoft,const ValueKey('taxonomy-icon-row-category')),
      for(final value in ts) _chip(Icons.sell_outlined,'#'+value,ArvinColors.tag,ArvinColors.tagSoft,ValueKey('taxonomy-icon-row-tag-'+value)),
    ];
    if(children.isEmpty) return const SizedBox.shrink();
    return Directionality(textDirection:TextDirection.rtl,child:Row(key:const ValueKey('taxonomy-icon-row'),children:[for(var i=0;i<children.length;i++)... [if(i>0)const SizedBox(width:5),Flexible(child:children[i])]]));
  }
  Widget _chip(IconData icon,String label,Color color,Color soft,Key key)=>Container(key:key,constraints:const BoxConstraints(minHeight:28),padding:const EdgeInsets.symmetric(horizontal:7,vertical:5),decoration:BoxDecoration(color:soft,borderRadius:BorderRadius.circular(9),border:Border.all(color:color.withValues(alpha:.28))),child:Row(mainAxisSize:MainAxisSize.min,children:[Icon(icon,size:14,color:color),const SizedBox(width:4),Flexible(child:Text(label,maxLines:1,overflow:TextOverflow.ellipsis,style:TextStyle(color:color,fontSize:10.5,fontWeight:FontWeight.w800)))]));
}
