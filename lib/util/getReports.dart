import 'package:provider/provider.dart' as provider;
import 'package:titikkita/controller/cmdbuild_controller.dart';
import 'package:titikkita/state/local_provider.dart';

Future<void> getReportData(context, cardName,id) async {
  try {
    var data = await CmdbuildController.getReportData(context,cardName,id);
    if (data.length != 0) {
      await provider.Provider.of<LocalProvider>(context, listen: false)
          .updateReportList(data, cardName);
    } else {
      await provider.Provider.of<LocalProvider>(context, listen: false)
          .updateReportList([],cardName);
    }
  } catch (e) {
    // goToPage(context, ErrorView());
    print(
        'Got error when try to fecth report data. Error:$e');
  }
}
