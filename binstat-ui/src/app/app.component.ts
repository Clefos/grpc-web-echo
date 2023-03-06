import {Component, OnInit} from '@angular/core';
import {EchoServiceClient} from "../proto/binstat.pbsc";
import {EchoRequest} from "../proto/binstat.pb";

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent implements OnInit {

  inputText = '';

  readonly responses: Array<string> = [];

  constructor(
    private echoServiceClient: EchoServiceClient
  ) {
  }

  public ngOnInit() {
  }

  clicked() {
    const req = new EchoRequest();
    req.message = this.inputText;
    this.inputText = '';
    this.echoServiceClient.echo(req)
      .subscribe(resp => this.responses.push(resp.message));
  }

}
