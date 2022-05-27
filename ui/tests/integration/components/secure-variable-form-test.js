import { module, test } from 'qunit';
import { setupRenderingTest } from 'ember-qunit';
import { hbs } from 'ember-cli-htmlbars';
import { componentA11yAudit } from 'nomad-ui/tests/helpers/a11y-audit';
import { click, findAll, render } from '@ember/test-helpers';

module('Integration | Component | secure-variable-form', function (hooks) {
  setupRenderingTest(hooks);

  test('passes an accessibility audit', async function (assert) {
    assert.expect(1);
    await render(hbs`<SecureVariableForm />`);
    await componentA11yAudit(this.element, assert);
  });

  test('shows a single row by default and modifies on "Add More" and "Delete"', async function (assert) {
    assert.expect(4);

    await render(hbs`<SecureVariableForm />`);

    assert.equal(
      findAll('div.key-value').length,
      1,
      'A single KV row exists by default'
    );

    await click('.key-value button.add-more');

    assert.equal(
      findAll('div.key-value').length,
      2,
      'A second KV row exists after adding a new one'
    );

    await click('.key-value button.add-more');

    assert.equal(
      findAll('div.key-value').length,
      3,
      'A third KV row exists after adding a new one'
    );

    await click('.key-value button.delete-row');

    assert.equal(
      findAll('div.key-value').length,
      2,
      'Back down to two rows after hitting delete'
    );
  });

  test('Values can be toggled to show/hide', async function (assert) {
    assert.expect(6);

    await render(hbs`<SecureVariableForm />`);
    await click('.key-value button.add-more'); // add a second variable

    findAll('input.value-input').forEach((input, iter) => {
      assert.equal(
        input.getAttribute('type'),
        'password',
        `Value ${iter + 1} is hidden by default`
      );
    });

    await click('.key-value button.show-hide-values');
    findAll('input.value-input').forEach((input, iter) => {
      assert.equal(
        input.getAttribute('type'),
        'text',
        `Value ${iter + 1} is shown when toggled`
      );
    });

    await click('.key-value button.show-hide-values');
    findAll('input.value-input').forEach((input, iter) => {
      assert.equal(
        input.getAttribute('type'),
        'password',
        `Value ${iter + 1} is hidden when toggled again`
      );
    });
  });
});
