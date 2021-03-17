import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ikinokat/pages/home/components/grid_products.dart';
import 'package:ikinokat/pages/my_products.dart/provider/getproducts_provider.dart';
import 'package:ikinokat/widgets/my_appbar.dart';
import 'package:ikinokat/widgets/my_custom_footer.dart';
import 'package:ikinokat/widgets/my_loading.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MyProductsPage extends StatelessWidget {
  const MyProductsPage({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GetProductsProvider(),
      child: Scaffold(
        appBar: MyAppBar(
          context: context,
          leadingType: AppBarBackType.Back,
          title: Text('My Products'),
        ),
        body: SafeArea(
          child: MyProductsPageContainer(),
        ),
      ),
    );
  }
}

class MyProductsPageContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<GetProductsProvider>(context);
    return state.loading
        ? MyLoadingWidget()
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
                child: SmartRefresher(
                  controller: state.refreshController,
                  enablePullUp: true,
                  onRefresh: state.getUserProducts,
                  onLoading: state.loadMoreProducts,
                  footer: MyCustomFooter(),
                  child: CustomScrollView(
                    slivers: <Widget>[
                      SliverToBoxAdapter(
                        child: GridProducts(
                          label: 'My Products',
                          products: state.userProducts,
                        ),
                      ),

                      /// all products by scrolling up
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
