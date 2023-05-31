import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:pos/Providers/CategoryProvider.dart';
import 'package:pos/Widegets/CategoryWidget.dart';
import 'package:provider/provider.dart';

class CreateCategory extends StatefulWidget {
  const CreateCategory({super.key});

  @override
  State<CreateCategory> createState() => _CreateCategoryState();
}

class _CreateCategoryState extends State<CreateCategory> {
  final TextEditingController name = TextEditingController();
  final GlobalKey<FormState> key = GlobalKey<FormState>();
  void submitForm() {
    if (!key.currentState!.validate()) {
      return;
    }
    Provider.of<CategoryProvider>(context, listen: false)
        .createCategory(name.text)
        .then((value) {
      Navigator.of(context).pop();
      name.text = '';
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future createCategoryBox() {
      return showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: const Text('Create Category'),
              content: SizedBox(
                height: 150,
                child: Form(
                  key: key,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        autofocus: true,
                        decoration: const InputDecoration(
                          labelText: 'Category Name',
                          border: OutlineInputBorder(gapPadding: 0),
                        ),
                        controller: name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          null;
                        },
                      ),
                      ElevatedButton(
                        onPressed: submitForm,
                        child: const Text('Save'),
                      )
                    ],
                  ),
                ),
              ),
            );
          });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Category'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createCategoryBox,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder(
        future: Provider.of<CategoryProvider>(context, listen: false)
            .getCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.hasError) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.connectionState == ConnectionState.done) {
            return CategoryWidget();
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
