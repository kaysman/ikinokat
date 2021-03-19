import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as GetLocale;
import 'package:ikinokat/config/validators.dart';
import 'package:ikinokat/pages/category/provider/category_provider.dart';
import 'package:ikinokat/pages/login/login_page.dart';
import 'package:ikinokat/pages/my_brands.dart/provider/getbrands_provider.dart';
import 'package:ikinokat/pages/my_products.dart/components.dart/upload_image.dart';
import 'package:ikinokat/pages/my_products.dart/pages/products_page.dart';
import 'package:ikinokat/pages/my_products.dart/provider/addproduct_provider.dart';
import 'package:ikinokat/pages/my_products.dart/provider/image_provider.dart';
import 'package:ikinokat/pages/profile/provider/user_provider.dart';
import 'package:ikinokat/utils/navigator.dart';
import 'package:ikinokat/widgets/my_custom_button.dart';
import 'package:ikinokat/widgets/my_dropdown.dart';
import 'package:ikinokat/widgets/my_loading.dart';
import 'package:ikinokat/widgets/my_textformfield.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

class ProductAddPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (_, state, child) {
        return state.getUser
            ? SafeArea(child: ProductAddPageContainer())
            : LoginPage();
      },
    );
  }
}

class ProductAddPageContainer extends StatefulWidget {
  @override
  _ProductAddPageContainerState createState() =>
      _ProductAddPageContainerState();
}

class _ProductAddPageContainerState extends State<ProductAddPageContainer> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _keywordController = TextEditingController();
  final TextEditingController _descripController = TextEditingController();
  String _category, _brand, _unit;
  List<File> _images = [];

  @override
  Widget build(BuildContext context) {
    /// states
    final cat_state = Provider.of<CategoryProvider>(context);
    final brand_state = Provider.of<GetBrandsProvider>(context);
    final imagestate = Provider.of<MyImageProvider>(context);
    final langCode = GetLocale.Get.locale.languageCode;

    /// dropdown lists
    final brands = brand_state.userBrands.map((e) => e.name).toList();
    final categories =
        cat_state.categories.map((e) => e.getName(langCode)).toList();
    final units = cat_state.units.map((e) => e.getName(langCode)).toList();

    /// login function
    var _submit = () async {
      final form = _formKey.currentState;
      if (form.validate()) {
        form.save();

        Map<String, dynamic> data = {
          'name_tm': _nameController.text,
          'cat_id': categories.indexOf(_category) + 1,
          'brand_id': brands.indexOf(_brand) + 1,
          'unit_id': units.indexOf(_unit) + 1,
        };

        if (imagestate.img1 != null) {
          print("Image 1: ${imagestate.img1.path}");
          _images.add(File(imagestate.img1.path));
        }
        if (imagestate.img2 != null) {
          print("Image 2: ${imagestate.img2.path}");
          _images.add(File(imagestate.img2.path));
        }
        if (imagestate.img3 != null) {
          print("Image 3: ${imagestate.img3.path}");
          _images.add(File(imagestate.img3.path));
        }

        Map<String, List<MultipartFile>> fileMap = {"images": []};
        for (File file in _images) {
          String filename = basename(file.path);
          fileMap['images'].add(MultipartFile(
            file.openRead(),
            await file.length(),
            filename: filename,
          ));
        }

        data.addAll(fileMap);
        var formData = FormData.fromMap(data);
        AddProductProvider state =
            Provider.of<AddProductProvider>(context, listen: false);
        await state.addUserProduct(formData);
        if (state.isAdded) {
          MyNavigator.push(MyProductsPage());
        } else {
          print('haryt goshulmady, product_add_page:111');
        }
      } else {
        print('form validation failed');
      }
    };

    return cat_state.loading
        ? MyLoadingWidget()
        : Container(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: 8,
                ),
                children: [
                  Row(
                    children: [
                      UploadSection(number: 1),
                      UploadSection(number: 2),
                      UploadSection(number: 3),
                    ],
                  ),
                  MyTextFormField(
                    controller: _nameController,
                    validator: validateName,
                    labelText: 'Name',
                    hintText: 'your name',
                  ),
                  MyTextFormField(
                    controller: _priceController,
                    validator: validatePassword,
                    labelText: 'Price',
                    hintText: 'product price',
                  ),
                  MyTextFormField(
                    controller: _quantityController,
                    validator: validatePassword,
                    labelText: 'Quantity',
                    hintText: 'minimum quantity',
                  ),
                  MyTextFormField(
                    controller: _keywordController,
                    validator: validatePassword,
                    labelText: 'Keyword',
                    hintText: 'keywords about product',
                  ),
                  MyTextFormField(
                    controller: _descripController,
                    validator: validatePassword,
                    labelText: 'Description',
                    hintText: 'description of product',
                  ),
                  MyDropDown(
                    list: categories,
                    currentSelected: _category,
                    labelText: 'Category',
                    hintText: 'select category',
                    onChanged: (value) {
                      setState(() {
                        _category = value;
                      });
                    },
                  ),

                  /// user brands
                  MyDropDown(
                    list: brands,
                    currentSelected: _brand,
                    labelText: 'Brand',
                    hintText: 'select brand',
                    onChanged: (value) {
                      setState(() {
                        _brand = value;
                      });
                    },
                  ),
                  MyDropDown(
                    list: units,
                    currentSelected: _unit,
                    labelText: 'Unit',
                    hintText: 'select unit',
                    onChanged: (value) {
                      setState(() {
                        _unit = value;
                      });
                    },
                  ),
                  Consumer<UserProvider>(
                    builder: (_, state, child) {
                      return state.loading
                          ? MyLoadingWidget()
                          : MyCustomButton(
                              onTap: _submit,
                              text: 'ADD PRODUCT',
                            );
                    },
                  ),
                ],
              ),
            ),
          );
  }
}

// Widget buildImageView(File image) {
//     final retrieveError =
//         _retrieveDataError != null ? Text(_retrieveDataError) : null;
//     if (retrieveError != null) {
//       return retrieveError;
//     }
//     if (image != null) {
//       return ClipRRect(
//         borderRadius: BorderRadius.circular(20),
//         child: Image.file(
//           image,
//           fit: BoxFit.fitHeight,
//         ),
//       );
//     } else if (pickImageError != null) {
//       return Text(
//         'Pick image error: $pickImageError',
//         textAlign: TextAlign.center,
//       );
//     } else {
//       return const Text(
//         'You have not yet picked an image.',
//         textAlign: TextAlign.center,
//       );
//     }
//     // Container(
//     //   // width: MediaQuery.of(context).size.width * 0.24,
//     //   // height: MediaQuery.of(context).size.width * 0.24,
//     //   height: 100,
//     //   width: 100,
//     //   margin: EdgeInsets.only(bottom: 12),
//     //   decoration: BoxDecoration(
//     //     color: Theme.of(context).backgroundColor.withOpacity(0.5),
//     //     borderRadius: BorderRadius.circular(20.0),
//     //   ),
//     //   child: image != null
//     //       ? ClipRRect(
//     //           borderRadius: BorderRadius.circular(20),
//     //           child: Image.file(
//     //             image,
//     //             fit: BoxFit.fitHeight,
//     //           ),
//     //         )
//     //       : CupertinoButton(
//     //           alignment: Alignment.center,
//     //           onPressed: () {
//     //             _showPicker(context, image);
//     //           },
//     //           child: Column(
//     //             children: [
//     //               Expanded(
//     //                 child: Image.asset(
//     //                   'assets/images/cloud.png',
//     //                   height: 20,
//     //                   color: Colors.grey,
//     //                 ),
//     //               ),
//     //               Row(
//     //                 mainAxisAlignment: MainAxisAlignment.center,
//     //                 children: [
//     //                   SvgPicture.asset(
//     //                     'assets/icons/add.svg',
//     //                     height: 15,
//     //                   ),
//     //                   SizedBox(width: 10),
//     //                   Text('Add product pictures'),
//     //                 ],
//     //               ),
//     //             ],
//     //           ),
//     //         ),
//     // );
//   }

//   // get image by camera
//   _imgFromCamera(File img) async {
//     try {
//       final pickedImage = await picker.getImage(
//         source: ImageSource.camera,
//         imageQuality: 100,
//       );
//       setState(() {
//         if (pickedImage != null) {
//           img = File(pickedImage.path);
//           // images.add(img);
//         } else {
//           print('No image selected.');
//         }
//       });
//     } catch (e) {
//       pickImageError = e;
//     }
//   }

//   // get image by gallery
//   _imgFromGallery(File img) async {
//     try {
//       final pickedImage = await picker.getImage(
//         source: ImageSource.gallery,
//         imageQuality: 100,
//       );
//       setState(() {
//         if (pickedImage != null) {
//           img = File(pickedImage.path);
//           // images.add(img);
//         } else {
//           print('No image selected.');
//         }
//       });
//     } catch (e) {
//       pickImageError = e;
//     }
//   }

//   void _showPicker(context, File image) {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext bc) {
//         return SafeArea(
//           child: Container(
//             child: Wrap(
//               children: <Widget>[
//                 ListTile(
//                   leading: new Icon(Icons.photo_library),
//                   title: new Text('Photo Library'),
//                   onTap: () {
//                     _imgFromGallery(image);
//                     Navigator.of(context).pop();
//                   },
//                 ),
//                 ListTile(
//                   leading: new Icon(Icons.photo_camera),
//                   title: new Text('Camera'),
//                   onTap: () {
//                     _imgFromCamera(image);
//                     Navigator.of(context).pop();
//                   },
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Future<void> retrieveLostData(File image) async {
//     final LostData response = await picker.getLostData();
//     if (response.isEmpty) {
//       return;
//     }
//     if (response.file != null) {
//       setState(() {
//         image = File(response.file.path);
//       });
//     } else {
//       _retrieveDataError = response.exception.code;
//     }
//   }
