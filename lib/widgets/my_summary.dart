import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'package:savings_app/blocs/settings_syncer/settings_syncer_bloc.dart';
import 'package:savings_app/blocs/settings_syncer/settings_syncer_events.dart';
import 'package:savings_app/models/account.dart';
import 'package:savings_app/models/fund.dart';
import 'package:savings_app/screens/account_details_screen.dart';
import 'package:savings_app/screens/fund_details_screen.dart';

class MySummary extends StatefulWidget {
  // Maybe unnecesary
  String token;

  List<Account> accounts;
  List<Fund> funds;


  MySummary(
      {@required this.token,
      @required this.accounts,
      @required this.funds}) ;

  @override
  _MySummaryState createState() => _MySummaryState();
}

class _MySummaryState extends State<MySummary> {

  void _refresh(BuildContext ctx){
    //TODO: I should update from the database and not from the server
    // so, calling the SummaryBloc it should be the right choice.
    BlocProvider.of<SettingsSyncerBloc>(ctx).add(SettingsSyncerSyncRequested());
  }
  Widget _fundsSectionWidget(List<Fund> funds) {

      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Funds",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Theme.of(context).primaryColor),
            ),
            Column(
              children: funds
                  .map((e) => InkWell(
                onTap: () {
                  Navigator.of(context)
                      .pushNamed(FundDetailsScreen.routeName,
                      arguments: {'fund': e, 'authToken': widget.token});
                },
                    child: ListTile(
                          title: Text(
                            e.name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: Text('\$${e.balance.toStringAsFixed(2)}'),
                        ),
                  ))
                  .toList(),
            )
          ],
        ),
      );

  }

  Widget _accountsSectionWidget(BuildContext ctx, List<Account> accounts) {

      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Accounts",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Theme.of(context).primaryColor),
            ),
            Column(
              children: accounts
                  .map((e) => InkWell(
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(AccountDetailsScreen.routeName,
                          arguments: {'account': e, 'authToken': widget.token})
                          .then((_) {
                            _refresh(ctx);
                          });
                        },
                        child: ListTile(
                          title: Text(
                            e.name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: Text('\$${e.balance.toStringAsFixed(2)}'),
                        ),
                      ))
                  .toList(),
            )
          ],
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(

        child: Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 18,
                  ),
                  _accountsSectionWidget(context, widget.accounts),
                  _fundsSectionWidget(widget.funds),
                ],
              ),
            ))
    );
  }
  }


