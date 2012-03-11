/* 
 * Fichier ajouté par JC pour avoir des fonctionnalités nouvelles de DataTable
 */
//plug in permettant d'ajouter le type comma-decimals aux colonnes'
jQuery.fn.dataTableExt.aTypes.unshift(function(a){var b="0123456789-,",c,d=!1;for(i=0;i<a.length;i++){c=a.charAt(i);if(b.indexOf(c)==-1)return null;if(c==","){if(d)return null;d=!0}}return"numeric-comma"}),jQuery.fn.dataTableExt.oSort["numeric-comma-asc"]=function(a,b){var c=a=="-"?0:a.replace(/,/,"."),d=b=="-"?0:b.replace(/,/,".");return c=parseFloat(c),d=parseFloat(d),c<d?-1:c>d?1:0},jQuery.fn.dataTableExt.oSort["numeric-comma-desc"]=function(a,b){var c=a=="-"?0:a.replace(/,/,"."),d=b=="-"?0:b.replace(/,/,".");return c=parseFloat(c),d=parseFloat(d),c<d?1:c>d?-1:0}