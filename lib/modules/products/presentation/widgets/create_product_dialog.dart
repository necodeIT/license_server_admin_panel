import 'package:flutter_modular/flutter_modular.dart';
import 'package:license_server_admin_panel/modules/app/app.dart';
import 'package:license_server_admin_panel/modules/products/products.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Prompts the user to enter details for a new product.
class CreateProductDialog extends StatefulWidget {
  /// Prompts the user to enter details for a new product.
  const CreateProductDialog({super.key, required this.showToast});

  /// {@macro show_toast}
  final ShowToast showToast;

  @override
  State<CreateProductDialog> createState() => _CreateProductDialogState();
}

class _CreateProductDialogState extends State<CreateProductDialog> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  bool isCreating = false;

  Future<void> _createProduct() async {
    if (isCreating) {
      return;
    }

    if (nameController.text.isEmpty || descriptionController.text.isEmpty) {
      return;
    }

    isCreating = true;

    Navigator.of(context).pop();

    final products = context.read<ProductsRepository>();

    final name = nameController.text;
    final description = descriptionController.text;

    final t = context.t;

    final loader = widget.showToast(
      (_, __) => SurfaceCard(
        child: Basic(
          title: Text(t.products_createProductDialog_creatingProduct),
          subtitle: Text(t.products_createProductDialog_creatingProductWith(name)),
          trailingAlignment: Alignment.center,
          trailing: const CircularProgressIndicator(),
        ),
      ),
      const Duration(minutes: 1),
    );

    try {
      await products.createProduct(
        name: name,
        description: description,
      );

      widget.showToast(
        (_, __) => SurfaceCard(
          child: Basic(
            title: Text(t.products_createProductDialog_createdProduct),
            subtitle: Text(t.products_createProductDialog_createdProductWith(name)),
            trailingAlignment: Alignment.center,
            trailing: Icon(RadixIcons.check, color: context.theme.colorScheme.primary),
          ),
        ),
      );

      loader.close();
    } catch (e) {
      loader.close();

      widget.showToast(
        (_, __) => SurfaceCard(
          child: Basic(
            title: Text(t.products_createProductDialog_errorCreating),
            subtitle: Text(t.products_createProductDialog_errorCreatingWith(name)),
            trailingAlignment: Alignment.center,
            trailing: const Icon(Icons.error),
          ),
        ),
      );
    } finally {
      isCreating = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(t.products_createProductDialog_createProduct),
      content: SizedBox(
        width: 500,
        child: Form(
          child: FormTableLayout(
            rows: [
              FormField<String>(
                key: const FormKey(#name),
                label: Text(t.products_createProductDialog_nameLabel),
                validator: NotEmptyValidator(message: t.products_createProductDialog_nameRequired),
                child: TextField(
                  controller: nameController,
                  placeholder: t.products_createProductDialog_namePlaceholder,
                ),
              ),
              FormField<String>(
                key: const FormKey(#description),
                label: Text(t.products_createProductDialog_descriptionLabel),
                validator: NotEmptyValidator(message: t.products_createProductDialog_descriptionRequired),
                child: TextArea(
                  controller: descriptionController,
                  placeholder: t.products_createProductDialog_descriptionPlaceholder,
                ),
              ),
            ],
          ),
          onSubmit: (_, __) => _createProduct(),
        ).withPadding(all: 20),
      ),
      actions: [
        Button.primary(
          onPressed: _createProduct,
          child: Text(t.global_create),
        ),
      ],
    );
  }
}
