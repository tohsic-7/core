<?php
/**
 * Copyright (c) 2013 Robin Appelman <icewind@owncloud.com>
 * This file is licensed under the Affero General Public License version 3 or
 * later.
 * See the COPYING-README file.
 */

namespace Test\Files\Storage\Wrapper;

use OCP\Files\Storage\IStorage;
use Test\Files\Storage\Storage;
use OC\Files\Storage\Wrapper\Wrapper;
use OC\Files\Storage\Local;

/**
 * Class WrapperTest
 *
 * @package Test\Files\Storage\Wrapper
 */
class WrapperTest extends Storage {
	/**
	 * @var string $tmpDir
	 */
	private $tmpDir;

	/**
	 * @var IStorage $storage
	 */
	private $storage;

	protected function setUp(): void {
		parent::setUp();

		$this->tmpDir = \OC::$server->getTempManager()->getTemporaryFolder();
		$this->storage = new Local(['datadir' => $this->tmpDir]);
		$this->instance = new Wrapper(['storage' => $this->storage]);
	}

	protected function tearDown(): void {
		\OC_Helper::rmdirr($this->tmpDir);
		parent::tearDown();
	}

	public function testInstanceOfStorageWrapper() {
		$this->assertTrue($this->instance->instanceOfStorage(Local::class));
		$this->assertTrue($this->instance->instanceOfStorage(Wrapper::class));
	}

	public function testUsePartFile() {
		$this->assertEquals($this->storage->usePartFile(), $this->instance->usePartFile());
	}
}
