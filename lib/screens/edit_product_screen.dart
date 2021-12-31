// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopify1_app/providers/product.dart';
import 'package:shopify1_app/providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routName = '/editproduct_screen';

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imgUrlControoler = TextEditingController();
  final _imgUrlFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  var _edidtingProduct =
      Product(id: null, title: "", description: "", price: 0, imgUrl: "");
  var _intialValues = {
    'title': '',
    'description': '',
    'price': '',
    'imgUrl': ''
  };
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    _imgUrlFocusNode.addListener(_updateImageUrl);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _edidtingProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _intialValues = {
          'title': _edidtingProduct.title,
          'description': _edidtingProduct.description,
          'price': _edidtingProduct.price.toString(),
          'imgUrl': "",
        };
      }
      _imgUrlControoler.text = _edidtingProduct.imageUrl;
      _isInit = false;
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _imgUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _imgUrlFocusNode.dispose();
    _imgUrlControoler.dispose();
    _descriptionFocusNode.dispose();
  }

  void _updateImageUrl() {
    if (!_imgUrlFocusNode.hasFocus) {
      if ((_imgUrlControoler.text.startsWith('http') &&
              _imgUrlControoler.text.startsWith('https')) ||
          (_imgUrlControoler.text.endsWith('.png') ||
              !_imgUrlControoler.text.endsWith('.jpg') ||
              !_imgUrlControoler.text.endsWith('.jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isVaild = _formKey.currentState.validate();
    if (!isVaild) {
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_edidtingProduct.id != null) {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_edidtingProduct.id, _edidtingProduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_edidtingProduct);
      } catch (e) {
        await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: const Text('an error occued'),
                  content: const Text('some thing went wrong'),
                  actions: [
                    FlatButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('ok'))
                  ],
                ));
      }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('edit product'),
          actions: [
            IconButton(
                onPressed: _saveForm,
                icon: const Icon(
                  Icons.save,
                ))
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        TextFormField(
                          initialValue: _intialValues['title'],
                          decoration: const InputDecoration(
                            labelText: 'Title',
                          ),
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_priceFocusNode);
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'pls enter provide title';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _edidtingProduct = Product(
                                title: value,
                                id: _edidtingProduct.id,
                                price: _edidtingProduct.price,
                                description: _edidtingProduct.description,
                                imageUrl: _edidtingProduct.imageUrl,
                                isFavorite: _edidtingProduct.isFavorite);
                          },
                        ),
                        TextFormField(
                          initialValue: _intialValues['price'],
                          decoration: const InputDecoration(
                            labelText: 'Price',
                          ),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          focusNode: _priceFocusNode,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_descriptionFocusNode);
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'pls enter price';
                            }

                            if (double.parse(value) == null) {
                              return 'pls enter availd price';
                            }

                            return null;
                          },
                          onSaved: (value) {
                            _edidtingProduct = Product(
                                title: _edidtingProduct.title,
                                id: _edidtingProduct.id,
                                price: double.parse(value),
                                description: _edidtingProduct.description,
                                imageUrl: _edidtingProduct.imageUrl,
                                isFavorite: _edidtingProduct.isFavorite);
                          },
                        ),
                        TextFormField(
                          initialValue: _intialValues['description'],
                          decoration: const InputDecoration(
                            labelText: 'Description',
                          ),
                          maxLines: 4,
                          keyboardType: TextInputType.multiline,
                          focusNode: _descriptionFocusNode,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'pls enter descreption';
                            }
                            if (value.length < 10) {
                              return 'its too short description';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _edidtingProduct = Product(
                                title: value,
                                id: _edidtingProduct.id,
                                price: _edidtingProduct.price,
                                description: value,
                                imageUrl: _edidtingProduct.imageUrl,
                                isFavorite: _edidtingProduct.isFavorite);
                          },
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              margin: const EdgeInsets.only(top: 8, right: 10),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 2, color: Colors.deepOrange)),
                              child: _imgUrlControoler.text.isEmpty
                                  ? const Text('entrer url')
                                  : FittedBox(
                                      child: Image.network(
                                        _imgUrlControoler.text,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: _imgUrlControoler,
                                decoration: const InputDecoration(
                                  labelText: 'Image url ',
                                ),
                                focusNode: _imgUrlFocusNode,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'pls enter an image url';
                                  }
                                  if (!value.startsWith('http') &&
                                      !value.startsWith('https')) {
                                    return 'pls enter vaild url';
                                  }
                                  if (!value.endsWith('png') &&
                                      !value.endsWith('jpg') &&
                                      !value.endsWith('jpeg')) {
                                    return 'pls enter vaild url';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _edidtingProduct = Product(
                                      title: value,
                                      id: _edidtingProduct.id,
                                      price: _edidtingProduct.price,
                                      description: _edidtingProduct.description,
                                      imageUrl: value,
                                      isFavorite: _edidtingProduct.isFavorite);
                                },
                              ),
                            )
                          ],
                        )
                      ],
                    )),
              ));
  }
}
